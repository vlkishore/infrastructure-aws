data "aws_ami" "app" {
  depends_on =  [null_resource.packer]
  filter {
    name   = "tag:Name"
    values = [local.ami_name]
  }

  most_recent = true
  owners      = ["self"]
}

# userdata for app
data "template_file" "app" {
  template = "${file("${path.module}/../image-config/app.tpl")}"

  vars = {    
    ENV     = "${var.name}"
  }
}
