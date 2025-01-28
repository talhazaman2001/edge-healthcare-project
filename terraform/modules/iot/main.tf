resource "aws_iot_thing" "patient_device" {
    name = "${var.environment}-patient-device"
}

# IoT Policy
resource "aws_iot_policy" "greengrass_iot_policy" {
    name = "${var.environment}-greengrass-iot-policy"
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "greengrass:Discover",
                    "greengrass:ListCoreDefinitionVersions",
                    "greengrass:GetCoreDefinition",
                    "iot:Connect"
                ]
                Resource = "arn:aws:greengrass:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/*"
            },
            {
                Effect = "Allow"
                Action = [
                    "iot:Connect",
                    "iot:Publish",
                    "iot:Subscribe",
                    "iot:Receive"
                ]
                Resource = "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:thing/${aws_iot_thing.patient_device.name}"
            }
        ]
    })
}

# IoT Certificate
resource "aws_iot_certificate" "iot_cert" {
    active = true
}

# Certificate and Policy Attachments
resource "aws_iot_thing_principal_attachment" "iot_thing_cert_attachment" {
    thing = aws_iot_thing.patient_device.name
    principal = aws_iot_certificate.iot_cert.arn
}

resource "aws_iot_policy_attachment" "iot_policy_attachment" {
    policy = aws_iot_policy.greengrass_iot_policy.name
    target = aws_iot_certificate.iot_cert.arn
}

# IoT Topic Rule
resource "aws_iot_topic_rule" "iot_rule" {
    name = "${var.environment}_iot_data_rule"
    description = "Rule to send IoT data to Kinesis"
    enabled = true
    sql = "SELECT * FROM 'iot/data'"
    sql_version = "2016-03-23"

    kinesis {
        stream_name = var.kinesis_stream_name
        role_arn = var.iot_core_role_arn
    }

    tags = {
        Environment = var.environment
        Terraform = "true"
    }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
