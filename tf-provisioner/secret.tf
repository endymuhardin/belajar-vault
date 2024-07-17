resource "vault_generic_secret" "aplikasi-belajar" {
  path = "secret/aplikasi/belajar"
  data_json = <<EOF
    {
        "SPRING_DATASOURCE_PASSWORD" : "belajar-vault-123",
        "SPRING_DATASOURCE_URL" : "jdbc:postgresql://localhost/belajar-vault",
        "SPRING_DATASOURCE_USERNAME" : "belajar"
    }
  EOF
}