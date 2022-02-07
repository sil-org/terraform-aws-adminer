output "adminer_url" {
  value = var.enable ? cloudflare_record.adminerdns[0].hostname : "(disabled)"
}
