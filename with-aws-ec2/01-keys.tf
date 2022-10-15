resource "tls_private_key" "user1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "user1" {
  key_name   = "user1"
  public_key = tls_private_key.user1.public_key_openssh

  # Create "user1_private_key.pem" to current local directory
  provisioner "local-exec" {
    command = "echo '${tls_private_key.user1.private_key_pem}' > ./user1_private_key.pem"
  }
}

# use "terraform output -raw private_key"
output "private_key" {
  value     = tls_private_key.user1.private_key_pem
  sensitive = true
}