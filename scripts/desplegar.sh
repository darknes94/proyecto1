#!/bin/bash
# Proyecto 1 · Despliegue del servidor web de Librería Tinta
set -euo pipefail
export AWS_PAGER=""           # evita que la salida se abra en un visor y detenga el script

REGION="us-east-1"
SUBNET_ID="subnet-0d84c933bd1ac0d41"
VPC_ID="vpc-04c54e1c692935e6a"
MI_IP="178.236.127.194/32"
ALUMNO="Marinés Antón"

# 1. AMI más reciente de Amazon Linux 2023
AMI_ID=$(aws ssm get-parameters --region "$REGION" \
  --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query "Parameters[0].Value" --output text)

# 2. Grupo de seguridad
SG_ID=$(aws ec2 create-security-group --region "$REGION" \
  --group-name libreria-web-cli-sg \
  --description "Web Libreria Tinta (CLI)" \
  --vpc-id "$VPC_ID" \
  --query "GroupId" --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID --protocol tcp --port 22 --cidr "$MI_IP"

# 3. Instancia
INSTANCE_ID=$(aws ec2 run-instances --region "$REGION" \
  --image-id "$AMI_ID" \
  --instance-type t3.micro \
  --key-name vockey \
  --subnet-id "$SUBNET_ID" \
  --security-group-ids "$SG_ID" \
  --user-data file://user-data1.sh \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=libreria-web-cli},{Key=Proyecto,Value=P1},{Key=Alumno,Value=$ALUMNO}]" \
  --query "Instances[0].InstanceId" --output text)

echo "Instancia creada: $INSTANCE_ID"

# Esperar a que la instancia esté en estado running
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Obtener su IP pública y guardarla en la variable IP
IP=$(aws ec2 describe-instances --region "$REGION" --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

echo "Abre en el navegador: http://$IP"
