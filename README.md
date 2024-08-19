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
                path "secret/data/aplikasi-belajar" {
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
    vault_generic_secret.aplikasi-belajar: Creation complete after 0s [id=secret/aplikasi-belajar]
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
    path "secret/data/aplikasi-belajar" {
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
    vault kv get secret/aplikasi-belajar
    ```

    Outputnya seperti ini

    ```
    ======== Secret Path ========
    secret/data/aplikasi-belajar

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

8. Apabila kita restart vault yang dijalankan dengan opsi `-dev`, datanya akan hilang semua. Untuk itu, kita perlu reset terraform supaya bisa melakukan `apply` lagi. Hapus file dan folder yang menyimpan state terraform

    ```
    rm -rf terraform.tfstate
    ```
    
    Setelah itu kita bisa jalankan lagi terraform agar policy, role, dan secret terisi kembali

    ```
    terraform apply
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
    VAULT_TOKEN="hvs.CAESILZwZ9W8KaCUKDQVEvdpskdEgGoit2bUn13xOXJ-tGj3Gh4KHGh2cy42OHdnNkh5TThlZjZFVmp0RzVyeFo1elg" vault kv get secret/aplikasi-belajar
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

## Menjalankan Vault dengan Docker Compose ##

1. Jalankan docker compose

    ```
    docker compose up
    ```

2. Buka terminal baru, cari tahu daftar container yang sedang berjalan

    ```
    docker ps -a
    ```

    Outputnya seperti ini

    ```
    CONTAINER ID   IMAGE             COMMAND                  CREATED       STATUS         PORTS                              NAMES
    e284f2b9e394   postgres          "docker-entrypoint.s…"   4 hours ago   Up 7 seconds   0.0.0.0:5432->5432/tcp             belajar-vault-db-belajar-1
    cacdedadab92   hashicorp/vault   "docker-entrypoint.s…"   4 hours ago   Up 8 seconds   8200/tcp, 0.0.0.0:8288->8288/tcp   belajar-vault-vault-1
    ```

    Container yang menjalankan Vault namanya adalah `belajar-vault-vault-1`

3. Masuk ke container `belajar-vault-vault-1` dan jalankan shell `sh` di dalam container

    ```
    docker exec -it belajar-vault-vault-1 sh
    ```

4. Set environment variable agar bisa membaca dan menulis data di Vault

    ```
    export VAULT_ADDR='http://127.0.0.1:8288'
    export VAULT_TOKEN='root-token-for-dev-purpose-only'
    ```

5. Ambil data `role-id`

    ```
    vault read auth/approle/role/belajar/role-id
    ```

6. Generate `secret-id`

    ```
    vault write -force auth/approle/role/belajar/secret-id
    ```

7. Generate `secret-id` yang di-wrap

    ```
    vault write -force -wrap-ttl=1m auth/approle/role/belajar/secret-id
    ```

## Menjalankan Aplikasi Spring Boot ##

Ada beberapa opsi authentication:

* Static Token
* Trusted Orchestrator / AppRole
* Trusted Platform

Penggunaan authentication model `token` tidak direkomendasikan, karena sulitnya mengamankan token.

### AppRole Authentication ###

Ada dua metode yang bisa dipilih:

* Plaintext Secret Id
* Wrapped Secret Id

#### Metode Plaintext Secret Id ####

1. Ambil `role-id` dari vault

    ```
    vault read auth/approle/role/belajar/role-id
    ```

    Outputnya seperti ini

    ```
    Key        Value
    ---        -----
    role_id    bcad7c7a-65c7-efc1-84d1-c69d257cc219
    ```

2. Ambil `secret-id` dari vault

    ```
    vault write -force auth/approle/role/belajar/secret-id
    ```

    Outputnya seperti ini

    ```
    Key                   Value
    ---                   -----
    secret_id             87af52b1-80ba-d36b-3620-d66f6d012278
    secret_id_accessor    3a8160ee-c290-3fac-d137-57c31946bf71
    secret_id_num_uses    0
    secret_id_ttl         0s
    ```

3. Set `role-id` di `application.properties` atau environment variable

    * application properties

        ```
        spring.cloud.vault.app-role.role-id=bcad7c7a-65c7-efc1-84d1-c69d257cc219
        ```

    * environment variable

        ```
        SPRING_CLOUD_VAULT_APPROLE_ROLEID='bcad7c7a-65c7-efc1-84d1-c69d257cc219'
        ```

4. Set `secret-id` di environment variable pada saat menjalankan aplikasi

    ```
    SPRING_CLOUD_VAULT_APPROLE_SECRETID='87af52b1-80ba-d36b-3620-d66f6d012278' mvn clean spring-boot:run
    ```

#### Metode Wrapped Secret Id ####

1. Ambil `role-id` dari vault

    ```
    vault read auth/approle/role/belajar/role-id
    ```

    Outputnya seperti ini

    ```
    Key        Value
    ---        -----
    role_id    bcad7c7a-65c7-efc1-84d1-c69d257cc219
    ```

2. Ambil `secret-id` dari vault dalam format terbungkus (wrapped-response)

    ```
    vault write -wrap-ttl=60s -force auth/approle/role/belajar/secret-id
    ```

    Outputnya seperti ini

    ```
    Key                              Value
    ---                              -----
    wrapping_token:                  hvs.CAESIBapJpXJKSeYcU6vl29b8wMU9_8nkWrbTla9MB8ZOy_CGh4KHGh2cy5hWENGN1hPNXN1eDVDMUF5ZVdUME1wWDk
    wrapping_accessor:               ZWZJmvO1sOknqmTLG72AuxM1
    wrapping_token_ttl:              1m
    wrapping_token_creation_time:    2024-07-19 03:10:03.636117344 +0000 UTC
    wrapping_token_creation_path:    auth/approle/role/belajar/secret-id
    wrapped_accessor:                318d284b-ff45-abbc-4a03-27f3d90b495f
    ```

3. Set `role-id` di `application.properties` atau environment variable

    * application properties

        ```
        spring.cloud.vault.app-role.role-id=bcad7c7a-65c7-efc1-84d1-c69d257cc219
        ```

    * environment variable

        ```
        SPRING_CLOUD_VAULT_APPROLE_ROLEID='bcad7c7a-65c7-efc1-84d1-c69d257cc219'
        ```

4. Set `wrapping_token` di environment variable pada saat menjalankan aplikasi

    ```
    SPRING_CLOUD_VAULT_APPROLE_ROLEID='bcad7c7a-65c7-efc1-84d1-c69d257cc219' SPRING_CLOUD_VAULT_TOKEN='hvs.CAESIBapJpXJKSeYcU6vl29b8wMU9_8nkWrbTla9MB8ZOy_CGh4KHGh2cy5hWENGN1hPNXN1eDVDMUF5ZVdUME1wWDk' mvn clean spring-boot:run
    ```

## Menjalankan Vault di Kubernetes ##

1. Pastikan kubernetes cluster sudah berjalan

    ```
    kubectl cluster-info
    ```

2. Instalasi Repo Vault di Helm local

    ```
    helm repo add hashicorp https://helm.releases.hashicorp.com
    helm repo update
    ```

3. Deploy Vault di k8s local

    ```
    helm install vault hashicorp/vault \
    --set "server.dev.enabled=true" \
    --set "injector.enabled=false" \
    --set "csi.enabled=true" \
    --set='ui.enabled=true' 

4. Cek instalasi Vault di helm

    ```
    helm list
    ```

    dan di kubernetes

    ```
    kubectl get all
    ```

5. Apabila menggunakan podman, kubernetes providernya adalah `kind`. Untuk itu, kita harus melakukan port-forwarding secara manual.

    ```
    kubectl port-forward service/vault-ui 8200:8200
    ```

6. UI Vault bisa dibrowse di `http://localhost:8200`

7. Jalankan terraform script seperti langkah di atas.

## Docker Image untuk aplikasi Spring Boot ##

1. Build image menggunakan `spring-boot-maven-plugin`

    ```
    mvn clean spring-boot:build-image
    ```

2. Push image ke docker hub

    ```
    docker push endymuhardin/belajar-vault
    ```

    atau menggunakan podman

    ```
    podman push endymuhardin/belajar-vault
    ```

3. Melihat daftar image di dockerhub

    ```
    curl -L -X GET \
    -H "Accept: application/json" \
    https://hub.docker.com/v2/repositories/endymuhardin/ | jq
    ```

4. Menghapus image

    ```
    curl -i -X DELETE \
    -H "Accept: application/json" \
    -H "Authorization: Bearer $DOCKERHUB_TOKEN" \
    https://hub.docker.com/v2/repositories/endymuhardin/nama-image/
    ```

## Mendeploy Aplikasi Spring Boot ke Kubernetes ##

1. Pastikan kubernetes cluster sudah ready

    ```
    kubectl cluster-info
    kubectl get nodes
    ```

2. Deploy configmap dan secret

    ```
    kubectl apply -f 00-configmap.yml
    kubectl apply -f 00-secret.yml
    ```

    Cek hasilnya

    ```
    kubectl get configmap, secret
    kubectl describe configmap/konfigurasi-app-belajar
    kubectl describe secret/secret-app-belajar
    ```

3. Deploy database

    ```
    kubectl apply -f 01-database.yml
    ```

4. Deploy aplikasi

    ```
    kubectl apply -f 02-aplikasi.yml
    ```

5. Cek hasilnya

    ```
    kubectl get pvc,pod,deployment,svc
    ```