# FIXTURE: insecure network, database, IAM, and logging config for IaC scanning. Do not apply.

resource "aws_security_group" "wide_open" {
  name        = "tigergate-fixture-open"
  description = "fixture"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 65535
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "public_unencrypted" {
  identifier              = "tigergate-fixture-db"
  engine                  = "postgres"
  engine_version          = "11.1"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "tg_admin"
  password                = "Pr0dDbP4ssw0rd!"
  publicly_accessible     = true
  storage_encrypted       = false
  backup_retention_period = 0
  deletion_protection     = false
  skip_final_snapshot     = true
  iam_database_authentication_enabled = false
}

resource "aws_iam_policy" "admin_star" {
  name = "tigergate-fixture-admin"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}

resource "aws_iam_user_policy" "inline_star" {
  name = "tigergate-fixture-inline"
  user = "ci-user"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = ["s3:*", "iam:*"], Resource = "*" }]
  })
}

resource "aws_instance" "imdsv1" {
  ami                         = "ami-12345678"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.wide_open.id]
  user_data                   = "export AWS_SECRET_ACCESS_KEY=not-a-real-key"

  metadata_options {
    http_tokens = "optional"
  }

  root_block_device {
    encrypted = false
  }
}

resource "aws_ebs_volume" "unencrypted" {
  availability_zone = "us-east-1a"
  size              = 10
  encrypted         = false
}

resource "aws_s3_bucket_acl" "public_read" {
  bucket = aws_s3_bucket.public_fixture.id
  acl    = "public-read-write"
}

resource "aws_cloudtrail" "no_validation" {
  name                       = "tigergate-fixture-trail"
  s3_bucket_name             = aws_s3_bucket.public_fixture.id
  enable_log_file_validation = false
  is_multi_region_trail      = false
}

resource "aws_kms_key" "no_rotation" {
  description         = "fixture"
  enable_key_rotation = false
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/fixture/abc"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/fixture/abc"
  }
}

resource "aws_eks_cluster" "public_api" {
  name     = "tigergate-fixture"
  role_arn = "arn:aws:iam::123456789012:role/eks"

  vpc_config {
    subnet_ids              = ["subnet-12345678"]
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }
}
