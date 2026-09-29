
variable "bobine_ed25519_private_key_hex" {
  description = "Ed25519 private key hex for bobine"
  type        = string
  sensitive   = true
}

variable "bobine_ed25519_public_key_hex" {
  description = "Ed25519 public key hex for bobine"
  type        = string
  sensitive   = true
}
