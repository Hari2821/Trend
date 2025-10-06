##########################################
# 8️⃣  Variable for Key Pair
##########################################
variable "key_name" {
  description = "Name of the existing AWS key pair to SSH into EC2"
  type        = string
}

