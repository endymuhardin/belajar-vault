resource "vault_generic_secret" "aplikasi-belajar" {
  path = "secret/aplikasi-belajar"
  data_json = <<EOF
    {
        "spring.datasource.url" : "jdbc:postgresql://localhost/belajar-vault",
        "spring.datasource.username" : "belajar",
        "spring.datasource.password" : "belajar-vault-123"
    }
  EOF
}