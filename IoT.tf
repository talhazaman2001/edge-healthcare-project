# Create IoT thing
resource "aws_iot_thing" "patient_device" {
    name = "patient-device"
}

# IAM Role for IoT Thing to interact with IoT Greengrass
resource "aws_iam_role" "iot_role" {
    name = "iot_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "credentials.iot.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }]
    })
}

# IAM Policy for this purpose
resource "aws_iam_policy" "greengrass_iot_policy" {
    name = "greengrass-iot-policy"
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "greengrass:Discover",
                "greengrass:ListCoreDefinitionVersions",
                "greengrass:GetCoreDefinition",
                "iot:Connect"
            ],
            Resource = "${aws_greengrass_group.critical_alerts_group.arn}"
        }]
    })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "greengrass_iot_policy_attach" {
    role = aws_iam_role.iot_role.name
    policy_arn = aws_iam_policy.greengrass_iot_policy.arn
}


# IAM Role for IoT Core to interact with Kinesis and IoT Greengrass
resource "aws_iam_role" "iot_core_role" {
    name = "iot_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "iot.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }]
    })
}

# IAM Policy for IoT Core to write to Kinesis
resource "aws_iam_policy" "iot_kinesis_policy" {
    name =  "iot_kinesis_policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "kinesis:PutRecord",
                "kinesis:PutRecords"
            ],
            Resource = "${aws_kinesis_stream.iot_data_stream.arn}"
        }]
    })
}

# IAM Policy for IoT Greengrass to interact with IoT Core
resource "aws_iam_policy" "greengrass_policy" {
    name =  "greengrass_policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "iot:Connect",
                "iot:Publish",
                "iot:Subscribe",
                "iot:Receive"
            ],
            Resource = "${aws_greengrass_group.critical_alerts_group.arn}"
        }]
    })
}

# Attach Policies to Role
resource "aws_iam_role_policy_attachment" "iot_kinesis_attach" {
    role = aws_iam_role.iot_core_role.name
    policy_arn = aws_iam_policy.iot_kinesis_policy.arn
}

resource "aws_iam_role_policy_attachment" "greengrass_policy_attach" {
    role = aws_iam_role.iot_core_role.name
    policy_arn = aws_iam_policy.greengrass_policy.arn
}

# Create IoT certificate to allow IoT Thing secure communication with IoT Greengrass
resource "aws_iot_certificate" "iot_cert" {
    active = true
}

# Attach Certificate to IoT Thing and Policy
resource "aws_iot_thing_principal_attachment" "iot_thing_cert_attachment" {
    thing = aws_iot_thing.patient_device.name
    principal = aws_iot_certificate.iot_cert.arn
}

resource "aws_iot_policy_attachment" "iot_policy_attachment" {
    policy = aws_iam_policy.iot_policy.name
    target = aws_iot_certificate.iot_cert.arn
}

# IoT Topic Rule to route data from IoT Core to Kinesis
resource "aws_iot_topic_rule" "iot_rule" {
    name = "iot-data-rule"
    description = "Rule to send IoT data to Kinesis"
    sql = "SELECT * FROM 'iot/data'"
    sql_version = "2016-03-23"
    enabled = true

    kinesis {
      stream_name = aws_kinesis_stream.iot_data_stream.name
      role_arn = aws_iam_role.iot_core_role.arn
    }
}

# Define Outputs
output "thing_arn" {
    value = aws_iot_thing.patient_device.arn
}

output "certificate_arn" {
    value = aws_iot_certificate.iot_cert.arn
}