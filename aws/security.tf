resource "aws_security_group" "kbn_sg" {
  vpc_id = aws_vpc.kbn_vpc.id

  # allow tcp/ssh from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow tcp/http on Kibana's dev server port
  ingress {
    from_port   = var.kibana_server_port
    to_port     = var.kibana_server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow outbound access from anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
