variable "my_ip_cidr" {
  description = "Your public IPv4 in CIDR form, e.g. 203.0.113.7/32 (SSH is allowed only from here)"
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0))
    error_message = "my_ip_cidr must look like 203.0.113.7/32"
  }
}