api_addr     = "VAULT_API_ADDRESS"
cluster_addr = "VAULT_CLUSTER_ADDRESS"

listener "tcp" {
    address                            = "0.0.0.0:8200"
    tls_client_ca_file                 = "/opt/vault/tls/ca.crt.pem"
    tls_cert_file                      = "/opt/vault/tls/vault.crt.pem"
    tls_key_file                       = "/opt/vault/tls/vault.key.pem"
    tls_require_and_verify_client_cert = false
    tls_disable_client_certs           = true 
}

backend "consul" {
    scheme  = "https"
    address = "127.0.0.1:8500"
    path    = "vault/"
    service = "vault"
}

    retry_join {
        auto_join_scheme = "http"
        auto_join        = "provider=aws addr_type=private_v4 tag_key=cluster_name tag_value=vault region=us-east-1"
    }

seal "awskms" {
    region = 
    kms_key_id = 
}

ui=true