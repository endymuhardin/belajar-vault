resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "belajar" {
  backend        = vault_auth_backend.approle.path
  role_name      = "belajar"
  token_policies = ["aplikasi-belajar-readonly"]
}