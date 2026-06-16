output "adminer_url" {
  description = "The URL to access Adminer"
  value       = var.enable ? try(cloudflare_record.adminerdns[0].hostname, "") : "(disabled)"
}

output "totp_secret" {
  description = "If enabled, the TOTP secret, base32-encoded, for adding to an authenticator app."
  value       = one(data.external.totp_formatter[*].result.base32)
  sensitive   = true
}
