import os
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client("ec2")

QUARANTINE_SG_ID   = os.environ["QUARANTINE_SG_ID"]
NACL_ID            = os.environ["NACL_ID"]
NACL_RULE_INBOUND  = int(os.environ["NACL_RULE_INBOUND"])
NACL_RULE_OUTBOUND = int(os.environ["NACL_RULE_OUTBOUND"])


def handler(event, context):
    instance_id = event.get("instance_id")
    if not instance_id:
        raise ValueError("event must contain 'instance_id'")

    # 1. 인스턴스 조회
    logger.info("Step 1: describing instance %s", instance_id)
    resp = ec2.describe_instances(InstanceIds=[instance_id])
    instances = resp["Reservations"][0]["Instances"] if resp["Reservations"] else []
    if not instances:
        raise RuntimeError(f"Instance {instance_id} not found")

    instance   = instances[0]
    vpc_id     = instance["VpcId"]
    private_ip = instance["PrivateIpAddress"]
    subnet_id  = instance["SubnetId"]
    enis       = instance.get("NetworkInterfaces", [])

    logger.info("Instance %s | VPC=%s | IP=%s | Subnet=%s | ENIs=%s",
                instance_id, vpc_id, private_ip, subnet_id,
                [e["NetworkInterfaceId"] for e in enis])

    if not enis:
        raise RuntimeError(f"Instance {instance_id} has no network interfaces")

    # 2. NACL이 서브넷에 연결돼 있는지 사전 확인 (변경 전 검증)
    logger.info("Step 2: verifying NACL %s is associated with subnet %s", NACL_ID, subnet_id)
    nacl_resp = ec2.describe_network_acls(NetworkAclIds=[NACL_ID])
    nacls = nacl_resp.get("NetworkAcls", [])
    if not nacls:
        raise RuntimeError(f"NACL {NACL_ID} not found")

    associated_subnets = [a["SubnetId"] for a in nacls[0].get("Associations", [])]
    if subnet_id not in associated_subnets:
        raise RuntimeError(
            f"NACL {NACL_ID} is not associated with subnet {subnet_id} "
            f"(associated: {associated_subnets})"
        )

    # 3. 원래 SG 목록 태그로 백업 후 ENI SG 교체
    backup_value = "|".join(
        f"{e['NetworkInterfaceId']}:{','.join(g['GroupId'] for g in e.get('Groups', []))}"
        for e in enis
    )
    logger.info("Step 3: tagging instance with original SGs: %s", backup_value)
    try:
        ec2.create_tags(
            Resources=[instance_id],
            Tags=[{"Key": "PreQuarantineSecurityGroups", "Value": backup_value}],
        )
    except Exception as e:
        logger.warning("Failed to tag instance with original SGs (quarantine continues): %s", e)

    logger.info("Replacing SG on %d ENI(s) with %s", len(enis), QUARANTINE_SG_ID)
    for eni in enis:
        eni_id = eni["NetworkInterfaceId"]
        ec2.modify_network_interface_attribute(
            NetworkInterfaceId=eni_id,
            Groups=[QUARANTINE_SG_ID],
        )
        logger.info("ENI %s → quarantine-sg applied", eni_id)

    # 4. placeholder 규칙의 CIDR을 인스턴스 IP(/32)로 교체
    quarantine_cidr = f"{private_ip}/32"
    logger.info("Step 4: replacing NACL placeholder rules with CIDR %s", quarantine_cidr)

    ec2.replace_network_acl_entry(
        NetworkAclId=NACL_ID,
        RuleNumber=NACL_RULE_INBOUND,
        Protocol="-1",
        RuleAction="deny",
        Egress=False,
        CidrBlock=quarantine_cidr,
    )
    logger.info("Inbound rule %d updated", NACL_RULE_INBOUND)

    ec2.replace_network_acl_entry(
        NetworkAclId=NACL_ID,
        RuleNumber=NACL_RULE_OUTBOUND,
        Protocol="-1",
        RuleAction="deny",
        Egress=True,
        CidrBlock=quarantine_cidr,
    )
    logger.info("Outbound rule %d updated", NACL_RULE_OUTBOUND)

    logger.info("Quarantine complete for instance %s (%s)", instance_id, private_ip)
    return {
        "instance_id":    instance_id,
        "private_ip":     private_ip,
        "quarantine_sg":  QUARANTINE_SG_ID,
        "nacl_id":        NACL_ID,
        "nacl_cidr":      quarantine_cidr,
        "status":         "quarantined",
    }
