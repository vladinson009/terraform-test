
variable "random_integer_min" {
  type        = number
  description = "Min random integer"
}
variable "random_integer_max" {
  type        = number
  description = "Max random integer"
}
variable "resource_group_name" {
  type        = string
  description = "Resource group name in Azure"

}
variable "resource_group_location" {
  type        = string
  description = "Resource group location in Azure"
}
variable "app_service_plan_name" {
  type        = string
  description = "App service plan name in Azure"
}
variable "app_service_plan_os" {
  type        = string
  description = "OS for service plan"

}
variable "app_service_name" {
  type        = string
  description = "App service name in Azure"
}
variable "app_service_dotnet_version" {
  type        = string
  description = "Version for dotnet (ex 6.0)"
}
variable "sql_server_name" {
  type        = string
  description = "Sql server name in Azure"
}
variable "sql_admin_login_username" {
  type        = string
  description = "Sql admin login username in Azure"
}
variable "sql_admin_login_password" {
  type        = string
  description = "Sql admin login password in Azure"
}
variable "sql_database_name" {
  type        = string
  description = "Sql database name in Azure"
}
variable "github_repo_url" {
  type        = string
  description = "Github repo url"
}
variable "firewall_rule_name" {
  type        = string
  description = "Firewall rule name in Azure"
}
variable "subscription_id" {
  type = string
}
variable "client_id" { type = string }
variable "client_secret" { type = string }
variable "tenant_id" { type = string }

