# TODO create an S3 bucket.

#resource "aws_s3_bucket_object" "textfile" {
#  bucket                 = local.files_bucket
#  key                    = "textfile.txt"
#  content                = data.template_file.textfile.rendered
#  server_side_encryption = "AES256"
#}
resource "aws_s3_bucket" "file_bucket" {
  bucket = "lxz_bucket"  
  acl    = "private"
}

resource "aws_s3_bucket_object" "file" {
  bucket = aws_s3_bucket.file_bucket.id
  key    = "lxz-file.txt"  
  source = "terraform/files/example.txt" 
  acl    = "private"
}