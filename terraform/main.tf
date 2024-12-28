
provider "aws" {
  region = "us-east-1"
}

variable "instances" {
  default = [
    { name = "app", instance_type = "t2.medium" },
    { name = "db", instance_type = "t2.large" }
  ]
}

resource "aws_instance" "example" {
  count         = length(var.instances)
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instances[count.index].instance_type

  tags = {
    Name = "${var.instances[count.index].name}-${count.index}"
  }
}

output "instance_ids" {
  value = aws_instance.example[*].id
}

output "instance_names" {
  value = aws_instance.example[*].tags["Name"]
}
