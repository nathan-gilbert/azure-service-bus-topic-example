output "app_service_url" {
  value = azurerm_linux_web_app.web_app.default_hostname
  description = "The default site hostname of the Flask web app."
}
