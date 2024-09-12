resource "vault_generic_secret" "aplikasi-belajar" {
  path = "secret/aplikasi-belajar"
  data_json = <<EOF
    {
        "spring.datasource.url" : "jdbc:postgresql://localhost/belajar-vault-k8s",
        "spring.datasource.username" : "belajar-k8s",
        "spring.datasource.password" : "belajar-vault-123-k8s"
    }
  EOF
}