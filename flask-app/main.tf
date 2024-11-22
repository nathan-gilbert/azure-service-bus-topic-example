terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.11"
    }
  }
  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}

  tenant_id = var.tenant_id
  subscription_id = var.subscription_id

  use_cli = true
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "flask-app-rg"
  location = "West US"
}

# Service Plan (Previously App Service Plan)
resource "azurerm_service_plan" "service_plan" {
  name                = "flask-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# App Service
resource "azurerm_linux_web_app" "web_app" {
  name                = "flask-web-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.service_plan.id

  app_settings = {
    # Add any necessary environment variables here
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "SERVICE_BUS_CONNECTION_STRING"      = azurerm_servicebus_namespace.namespace.default_primary_connection_string
    "TOPIC_NAME"                         = azurerm_servicebus_topic.topic.name
    "SUBSCRIPTION_NAME"                  = azurerm_servicebus_subscription.subscription.name
  }

  site_config {
    always_on = true
    application_stack {
      python_version = "3.11"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "flaskappstorage${random_string.unique_storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_string" "unique_storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Service Bus Namespace
resource "azurerm_servicebus_namespace" "namespace" {
  name                = "flaskappnamespace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "topic" {
  name         = "flaskapptopic"
  namespace_id = azurerm_servicebus_namespace.namespace.id
}

# Service Bus Subscription
resource "azurerm_servicebus_subscription" "subscription" {
  name             = "flaskappsubscription"
  topic_id         = azurerm_servicebus_topic.topic.id
  max_delivery_count = 10
}
