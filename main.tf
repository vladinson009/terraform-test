# terraform configs
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.54.0"
    }
  }
}
# Configure the Azure provider
provider "azurerm" {
  # Configuration options
  subscription_id = var.subscription_id
  features {}
}
# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = var.random_integer_min
  max = var.random_integer_max
}
# Create the resource group 
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${random_integer.ri.result}"
  location = var.resource_group_location
}
# Create the Linux App Service Plan
resource "azurerm_service_plan" "rp" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = var.app_service_plan_os
  sku_name            = "F1"
}
# Create the web app, pass in the App Service Plan ID 
resource "azurerm_linux_web_app" "webapp" {
  name                = "${var.app_service_name}-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.rp.id
  site_config {
    application_stack {
      dotnet_version = var.app_service_dotnet_version
    }
    always_on = false
  }
  connection_string {
    name = "DefaultConnection"
    type = "SQLAzure"
    # value = "Data Source=tcp:${fully qualified domain name of the MSSQL server},1433;Initial Catalog=${name of the SQL database};User ID=${username of the MSSQL server administrator};Password=${password of the MSSQL server administrator};Trusted_Connection=False; MultipleActiveResultSets=True;"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.db.name};User ID=${azurerm_mssql_server.sqlserver.administrator_login};Password=${azurerm_mssql_server.sqlserver.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
    # value = "test"
  }
}
# MSSQL SERVER
resource "azurerm_mssql_server" "sqlserver" {
  name                         = "${var.sql_server_name}-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login_username
  administrator_login_password = var.sql_admin_login_password

  tags = {
    environment = "production"
  }
}
# MSSQL DATABASE
resource "azurerm_mssql_database" "db" {
  name           = "${var.sql_database_name}-${random_integer.ri.result}"
  server_id      = azurerm_mssql_server.sqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  enclave_type   = "VBS"
  zone_redundant = false
  # storage_account_type = "Local"
  tags = {
    foo = "bar"
  }

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}
# Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "github" {
  app_id                 = azurerm_linux_web_app.webapp.id
  repo_url               = var.github_repo_url
  branch                 = "main"
  use_manual_integration = true
}
# FIREWALL RULE
resource "azurerm_mssql_firewall_rule" "example" {
  name             = "${var.firewall_rule_name}-${random_integer.ri.result}"
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
