variable "network_identity" {
  type = object({
    owner     = optional(string, "tech4life")
    workspace = string
    iteration = optional(number, 1)
  })
}

variable "resource_group" {
  type = object({
    id   = string
    name = string
  })
}

variable "location" {
  type = string
}

variable "search_location" {
  type = string
}

variable "deployments" {
  type = map(object({
    model = object({
      name    = string
      format  = string
      version = optional(string, null)
    })
    sku = object({
      name     = string
      capacity = optional(number, 1)
    })
  }))

  default = {}
}

variable "tags" {
  type = object({})
}

variable "role_assignments" {
  type = map(object({
    role_definition_name = string
    principal_id         = string
  }))

  default = {}
}
