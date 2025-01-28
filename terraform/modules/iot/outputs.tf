output "thing_arn" {
    value = aws_iot_thing.patient_device.arn
}

output "certificate_arn" {
    value = aws_iot_certificate.iot_cert.arn
}

output "certificate_pem" {
    value = aws_iot_certificate.iot_cert.certificate_pem
    sensitive = true
}

output "private_key" {
    value = aws_iot_certificate.iot_cert.private_key
    sensitive = true
}