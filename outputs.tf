output "adminer_url" {
  description = "The URL to access Adminer"
  value       = var.enable ? "https://${var.subdomain}.${var.cloudflare_domain}" : "(disabled)"
}

output "totp_secret" {
  description = "If enabled, the TOTP secret, base32-encoded, for adding to an authenticator app."
  value       = one(data.external.base64_to_base32[*].result.output)
  sensitive   = true
}
