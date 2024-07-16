# Terraform Script untuk Provision Vault #

1. Jalankan Vault di terminal #1

    ```
    vault server -dev -dev-root-token-id root
    ```

2. Buka terminal #2 dan set environment variable

    ```
    export VAULT_ADDR='http://127.0.0.1:8200'
    export VAULT_TOKEN='root'
    ```

3. Inisialisasi terraform

    ```
    terraform init
    ```

4. Jalankan script

    ```
    terraform apply
    ```

    Outputnya seperti ini

    ```
    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
    + create

    Terraform will perform the following actions:

    # vault_approle_auth_backend_role.belajar will be created
    + resource "vault_approle_auth_backend_role" "belajar" {
        + backend        = (known after apply)
        + bind_secret_id = true
        + id             = (known after apply)
        + role_id        = (known after apply)
        + role_name      = "belajar"
        + token_policies = [
            + "aplikasi-belajar-readonly",
            ]
        + token_type     = "default"
        }

    # vault_auth_backend.approle will be created
    + resource "vault_auth_backend" "approle" {
        + accessor        = (known after apply)
        + disable_remount = false
        + id              = (known after apply)
        + path            = (known after apply)
        + tune            = (known after apply)
        + type            = "approle"
        }

    # vault_generic_secret.aplikasi-belajar will be created
    + resource "vault_generic_secret" "aplikasi-belajar" {
        + data                = (sensitive value)
        + data_json           = (sensitive value)
        + delete_all_versions = false
        + disable_read        = false
        + id                  = (known after apply)
        + path                = "secret/aplikasi/belajar"
        }

    # vault_policy.aplikasi-belajar-readonly will be created
    + resource "vault_policy" "aplikasi-belajar-readonly" {
        + id     = (known after apply)
        + name   = "aplikasi-belajar-readonly"
        + policy = <<-EOT
                path "secret/data/aplikasi/belajar" {
                capabilities = ["read"]
                }
            EOT
        }

    Plan: 4 to add, 0 to change, 0 to destroy.

    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.
    ```

    Ketik `yes`

    ```
    vault_policy.aplikasi-belajar-readonly: Creating...
    vault_generic_secret.aplikasi-belajar: Creating...
    vault_auth_backend.approle: Creating...
    vault_policy.aplikasi-belajar-readonly: Creation complete after 0s [id=aplikasi-belajar-readonly]
    vault_generic_secret.aplikasi-belajar: Creation complete after 0s [id=secret/aplikasi/belajar]
    vault_auth_backend.approle: Creation complete after 0s [id=approle]
    vault_approle_auth_backend_role.belajar: Creating...
    vault_approle_auth_backend_role.belajar: Creation complete after 0s [id=auth/approle/role/belajar]
    ```

5. Cek apakah policy sudah terbentuk

    ```
    vault policy list
    ```

    Outputnya seperti ini 

    ```
    aplikasi-belajar-readonly
    default
    root
    ```

    Cek isinya apakah sesuai

    ```
    vault policy read aplikasi-belajar-readonly
    ```

    Outputnya seharusnya seperti ini

    ```
    path "secret/data/aplikasi/belajar" {
        capabilities = ["read"]
    }
    ```

6. Cek apakah `approle` sudah terbentuk

    ```
    vault list auth/approle/role
    ```

    Outputnya seperti ini

    ```
    Keys
    ----
    belajar
    ```

    Cek isinya

    ```
    vault read auth/approle/role/belajar
    ```

    Outputnya seperti ini

    ```
    Key                        Value
    ---                        -----
    bind_secret_id             true
    local_secret_ids           false
    secret_id_bound_cidrs      <nil>
    secret_id_num_uses         0
    secret_id_ttl              0s
    token_bound_cidrs          []
    token_explicit_max_ttl     0s
    token_max_ttl              0s
    token_no_default_policy    false
    token_num_uses             0
    token_period               0s
    token_policies             [aplikasi-belajar-readonly]
    token_ttl                  0s
    token_type                 default
    ```

7. Cek apakah secret sudah terbentuk

    ```
    vault kv get secret/aplikasi/belajar
    ```

    Outputnya seperti ini

    ```
    ======== Secret Path ========
    secret/data/aplikasi/belajar

    ======= Metadata =======
    Key                Value
    ---                -----
    created_time       2024-07-16T14:08:35.814983Z
    custom_metadata    <nil>
    deletion_time      n/a
    destroyed          false
    version            1

    =============== Data ===============
    Key                           Value
    ---                           -----
    SPRING_DATASOURCE_PASSWORD    belajar-vault-123
    SPRING_DATASOURCE_URL         jdbc:postgresql://localhost/belajar-vault
    SPRING_DATASOURCE_USERNAME    belajar
    ```

## Test Akses Approle ke Secret ##

1. Generate `secret-id` dengan response-wrapper

    ```
    vault write -wrap-ttl=60s -force auth/approle/role/belajar/secret-id
    ```

    Outputnya seperti ini

    ```
    Key                              Value
    ---                              -----
    wrapping_token:                  hvs.CAESIHaN0UeG4_cjHrYUBoQIxlcUsf8AUgE4Z9YodlURlsqXGh4KHGh2cy5jaFZrU2kyNFVTb0ZHY0pCRUxKSzFnM3c
    wrapping_accessor:               7RWJ7IhowGbMLvC42fnhr39P
    wrapping_token_ttl:              1m
    wrapping_token_creation_time:    2024-07-16 21:17:27.229761 +0700 WIB
    wrapping_token_creation_path:    auth/approle/role/belajar/secret-id
    wrapped_accessor:                bcad3b68-8945-f3a7-3b9d-226e2119a232
    ```

2. Tampilkan `role-id` untuk role `belajar`

    ```
    vault read auth/approle/role/belajar/role-id
    ```

    Outputnya seperti ini

    ```
    Key        Value
    ---        -----
    role_id    58981c5c-ed91-5778-a671-690635060d0d
    ```

3. Buka terminal baru, unwrap `secret-id` menggunakan `wrapping_token`

    ```
    VAULT_TOKEN="hvs.CAESIHaN0UeG4_cjHrYUBoQIxlcUsf8AUgE4Z9YodlURlsqXGh4KHGh2cy5jaFZrU2kyNFVTb0ZHY0pCRUxKSzFnM3c" vault unwrap
    ```

    Outputnya seperti ini

    ```
    Key                   Value
    ---                   -----
    secret_id             3b8fdb4d-a757-b34c-d3e1-0a89581af9f2
    secret_id_accessor    7bec4062-8b4a-a885-1276-575ae45b7ff9
    secret_id_num_uses    0
    secret_id_ttl         0s
    ```

4. Gunakan `role-id` dan `secret-id` untuk login dan mendapatkan token

    ```
    vault write auth/approle/login role_id='58981c5c-ed91-5778-a671-690635060d0d' secret_id='3b8fdb4d-a757-b34c-d3e1-0a89581af9f2'
    ```

    Outputnya seperti ini

    ```
    Key                     Value
    ---                     -----
    token                   hvs.CAESILZwZ9W8KaCUKDQVEvdpskdEgGoit2bUn13xOXJ-tGj3Gh4KHGh2cy42OHdnNkh5TThlZjZFVmp0RzVyeFo1elg
    token_accessor          67NZWW5hs0mpbPazA930arIu
    token_duration          768h
    token_renewable         true
    token_policies          ["aplikasi-belajar-readonly" "default"]
    identity_policies       []
    policies                ["aplikasi-belajar-readonly" "default"]
    token_meta_role_name    belajar
    ```

5. Gunakan `token` untuk membaca isi secret

    ```
    vault kv get secret/aplikasi/belajar
    ```

    Outputnya seperti ini

    ```
    ======== Secret Path ========
    secret/data/aplikasi/belajar

    ======= Metadata =======
    Key                Value
    ---                -----
    created_time       2024-07-16T14:08:35.814983Z
    custom_metadata    <nil>
    deletion_time      n/a
    destroyed          false
    version            1

    =============== Data ===============
    Key                           Value
    ---                           -----
    SPRING_DATASOURCE_PASSWORD    belajar-vault-123
    SPRING_DATASOURCE_URL         jdbc:postgresql://localhost/belajar-vault
    SPRING_DATASOURCE_USERNAME    belajar
    ```

6. Token tersebut harusnya cuma bisa membaca data, tidak bisa menghapus.

    ```
    VAULT_TOKEN="hvs.CAESILZwZ9W8KaCUKDQVEvdpskdEgGoit2bUn13xOXJ-tGj3Gh4KHGh2cy42OHdnNkh5TThlZjZFVmp0RzVyeFo1elg" vault kv delete secret/aplikasi/belajar
    ```

    Outputnya harusnya error seperti ini, karena policy-nya read only

    ```
    Error deleting secret/data/aplikasi/belajar: Error making API request.

    URL: DELETE http://127.0.0.1:8200/v1/secret/data/aplikasi/belajar
    Code: 403. Errors:

    * 1 error occurred:
        * permission denied
    ```