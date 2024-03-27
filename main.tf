provider "aws" {
    region = "ap-south-1"
   
}

# S3 bucket creation
resource "aws_s3_bucket" "example" {
  bucket = "godigital-task"

  tags = {
    Name        = "godigital-task"
    Environment = "Dev"
  }
}

# Postgres Database creation
resource "aws_db_instance" "postgres" {  // Updated resource name for clarity
  engine              = "postgres"
  engine_version      = "16.1"
  allocated_storage   = 20
  instance_class      = "db.t3.micro"
  identifier = "postgressql"
  db_name       = "postgres"  // Use 'name' argument for instance name
  username            = "postgres"
  password            = "ashher1234"  // Consider security recommendations below
  port                = 5432
  publicly_accessible  = true
}

#Creating ecr repository
resource "aws_ecr_repository" "my_new_repo" {
  name = "my-new-repo"          # Name of the repository
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Define IAM role for Lambda
resource "aws_iam_role" "lambda_role"{
    name = "lambda_role"
    assume_role_policy = jsonencode({
       Version = "2012-10-17",
       Statement = [
        {
          Action = "sts:AssumeRole",
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        }
       ]
    })  
}
# Attach a policy to the IAM role for full s3 access
resource "aws_iam_role_policy_attachment" "lambda_s3_full_access_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"  # S3 Full access
    role       =  aws_iam_role.lambda_role.name
}
# Attach a Lambda Basic Execution policy directly to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"  # Basic Lambda Execution Permissions
    role       =  aws_iam_role.lambda_role.name
}
# Attach a policy to the IAM role for full RDS access
resource "aws_iam_role_policy_attachment" "lambda_rds_full_access_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"  # RDS Full access
    role       =  aws_iam_role.lambda_role.name
}
# Attach a policy to the IAM role for Lambda VPC execution access
resource "aws_iam_role_policy_attachment" "vpc_access_policy" {
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
    role       =  aws_iam_role.lambda_role.name
  
}

#Create Lambda Function
resource "aws_lambda_function" "my_lambda_funtion" {
  function_name = "s3_rds_function"
  role          = "arn:aws:iam::411755664422:role/lambda_role"
  handler       = "lambda_function.lambda_handler"

  runtime = "provided.al2"    #Use "provideral2" for custom runtime like Docker

  image_uri = "411755664422.dkr.ecr.ap-south-1.amazonaws.com/my-new-repo:latest"

  package_type = "Image"
}