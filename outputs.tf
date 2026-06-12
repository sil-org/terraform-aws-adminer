output "adminer_url" {
  value = var.enable ? try(cloudflare_record.adminerdns[0].hostname, "") : "(disabled)"
}
