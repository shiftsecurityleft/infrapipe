resource "random_pet" "common" {
  length    = 2
  separator = ""
}

module "encrypted-s3" {
  source   = "./modules/encrypted-private-s3-bucket"
  
  S3_BUCKET = random_pet.common.id
  TAGS = local.common_tags
}

output "this_ssh_keyname" {
  description = "The SSH keypair name"
  value       = "${module.keys.this_ssh_keyname}"
}

