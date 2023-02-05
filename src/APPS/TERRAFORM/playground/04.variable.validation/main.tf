terraform {
  required_version = "= 1.3.3"
}

variable "r53_enabled" {
  type    = bool
  default = false
}

/**
 *
 * if `condition` returns true, variable passes the validation
 * if `condition` returns false, error_message is printed
 *
 */

variable "r53_zone_name" {
  type    = string
  default = ""

  validation {
    condition     = length(var.r53_zone_name) > 0
    error_message = "Err: r53_zone_name can not be empty string."
  }
}
