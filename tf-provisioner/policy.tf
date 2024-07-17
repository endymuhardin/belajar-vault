resource "vault_policy" "aplikasi-belajar-readonly" {
  name   = "aplikasi-belajar-readonly"
  policy = file("policies/aplikasi-belajar-readonly.hcl")
}