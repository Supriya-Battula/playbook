terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.0.81"
    }
  }
}

provider "azurerm" {
  features {}
}
