variable "satsale_xpub" {
  description = "Sensitive account-level mainnet extended public key for SatSale; never use a private key"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^(xpub|zpub)[1-9A-HJ-NP-Za-km-z]{107}$", var.satsale_xpub))
    error_message = "satsale_xpub must be a mainnet xpub or zpub, not a private key."
  }
  validation {
    condition     = var.satsale_bip == "BIP84" || !startswith(var.satsale_xpub, "zpub")
    error_message = "A zpub can only be used with BIP84."
  }

}

variable "satsale_bip" {
  description = "Account derivation used by the SatSale wallet: BIP44, BIP84 or BIP86"
  type        = string
  default     = "BIP84"

  validation {
    condition     = contains(["BIP44", "BIP84", "BIP86"], var.satsale_bip)
    error_message = "satsale_bip must be BIP44, BIP84 or BIP86."
  }
}

variable "satsale_port" {
  description = "Localhost-only SatSale port on the NAS"
  type        = number
  default     = 8000
}

variable "satsale_uid" {
  description = "Numeric UID of the deployment user owning the SatSale data and config"
  type        = number
}

variable "satsale_gid" {
  description = "Numeric GID of the deployment user owning the SatSale data"
  type        = number
}
