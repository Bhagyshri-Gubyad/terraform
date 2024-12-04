
resource "aws_iam_user" "tfm_user" {
  name = var.iam_user_name
}

resource "aws_iam_user_policy_attachment" "admin_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  user = aws_iam_user.tfm_user.id
}
# If the environment (e.g., EC2 instance or Lambda) has an IAM role 
# with necessary permissions attached, Terraform can use 
# those credentials instead of a user.
# or pre-existing user or cli and environment var 
# activities performed by user are tracalbe in cloudtrial 

resource "aws_s3_bucket" "tfm_bkt" {
  bucket = var.bucket_name

  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_versioning" "tfm_version_bkt" {
    bucket = aws_s3_bucket.tfm_bkt.id

    versioning_configuration {
      status = "Enabled"
    }
}
//to limit access to only authoruised user, here crated policy

resource "aws_s3_bucket_policy" "tfm_bucket_Policy" {
  bucket = aws_s3_bucket.tfm_bkt.id

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Effect = "Allow",
            Action = "s3:ListBucket",
            Resource = aws_s3_bucket.tfm_bkt.arn, 
            Principal = {
              AWS = aws_iam_user.tfm_user.arn
            }
          }
,
{
  Effect = "Allow",
  Action = ["s3:GetObject", "s3:PutObject"],
  Resource = "${aws_s3_bucket.tfm_bkt.arn}/*",
  Principal = {
    AWS = aws_iam_user.tfm_user.arn
  }
}
        ]
    })
  
}
 //y dynamo ? low latency, scalable , mulit az , native integration 
 //i.e tfm suport s3+dynamo


resource "aws_dynamodb_table" "tfm_db_table" {
    name = var.table_name
    billing_mode = "PAY_PER_REQUEST"  //def is provisioned if consister traffc 
    hash_key = "LockID"  //same statte file but diff version then toidentify
                          // & used as partition key to uniquely identify items in table 
    attribute {
      name = "LockID"  //must match hash key
      type = "S"
    }
  # lifecycle {
  #   prevent_destroy = true //ensure tht table  should not deleted by tfm accidently  
  # }

  tags = {
    Name = var.table_name
  }
}

output "iam_user_arn"{
    value = aws_iam_user.tfm_user.arn
}