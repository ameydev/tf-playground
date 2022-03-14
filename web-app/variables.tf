variable "additional_tags" {
  default     = {
      "project" = "web-app-sample"
      "managed-by" = "terraform"
  }
  description = "Additional resource tags"
  type        = map(string)
}

variable prefix {
    default = "web-app"
    description = "prefix for web-app instance names"
}

variable instance_type {
    default = "t2.micro"
}