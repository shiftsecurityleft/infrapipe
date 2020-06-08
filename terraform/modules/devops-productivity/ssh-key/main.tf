variable KEY_NAME {
}

resource "aws_key_pair" "this" {
  key_name = var.KEY_NAME
  #public_key = "insert ssh public key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZHei3l8iZPoQzat06elQGTy+hAhWqumI+7X+9CbGWf3geTyGXrAy11LiJm/w84Yua5Vr9B62eosDw773yXbcSl3XAPge2p3ZH1gYqWKmg7s64H5KFN4QwEQerf04h3CH7DzOGj6Z26qGjTzQmzdFi+GFV79v6Kt0v1/9JxPtNAMxx/5d3ivPygWhjiK/Wk+j67kUBkbsbd36oJ00J2ZBlOSbM0fjHgAjzFQJm6frLO7kTrtBVm3rihPMTPb2esw8/5WOp4PxiT1DBzp8E/TP5mHCKUQk2zCODTXMxwBYwhezsbLX7cTgZfkQMw6FlpOAQyDwzenMKbEfUctEkw6MenEOLNJIW34kvj1YtWNZL6/sujIiISJF/LzUuztab6u8N9pn5O+bbQfxfM/DPBwZYpPlciC9IxyfS9aCyccmhnPxfQ2nJJSfHwk6eZ50hnx2YC3hjYdH0/VpcdXkrxSDCl5DBqSC08jTngts1nq5B5QPLGpvPAo6I5gJqFBYeedA9SMJWI1qVq5TG6YWZLkjER5LsVIGq6fmA1ZMN3XtZkt+7qNsrLeT58AZGKr/rSyaa8ug9HbmSkM4iHphU5PSaL5Qr16S82IcpbymyHvC9WHthq8MbZXG49g28Cqclqd03Zs2n3RBv5B4RzRsyrfjuid4YRWYhpUmU8h55L5WTYQ=="
}

output "this_ssh_keyname" {
  description = "The name of the ssh public key"
  value       = "${aws_key_pair.this.key_name}"
}
