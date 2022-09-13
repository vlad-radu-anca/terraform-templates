resource "aws_cognito_identity_pool" "this" {
    for_each = toset(var.identity_pool_name)
    identity_pool_name = "${each.value}"
    allow_unauthenticated_identities = var.allow_unauthenticated_identities
    developer_provider_name = var.developer_provider_name
    dynamic "cognito_identity_providers" {
        for_each = var.cognito_identity_providers
        content{
            client_id = cognito_identity_providers.value.client_id
            provider_name = cognito_identity_providers.value.provider_name
            server_side_token_check = cognito_identity_providers.value.server_side_token_check
        }

    }
    saml_provider_arns = var.saml_provider_arns
    supported_login_providers = var.supported_login_providers
    tags = {
        Terraform                       = true
        Environment                     = var.environment
        Name                            = "${each.value}-cognito-identity-pool"
    }
}

resource "aws_cognito_identity_pool_roles_attachment" "this" { 
    identity_pool_id = var.identity_pool_id
    dynamic "role_mapping" {
        for_each = var.role_mapping
        content {
            identity_provider = role_mapping.value.identity_provider
            ambiguous_role_resolution = role_mapping.value.ambiguous_role_resolution
            dynamic "mapping_rule" {
                for_each = role_mapping.value.mapping_rule
                content {
                    claim = mapping_rule.value.claim
                    match_type = mapping_rule.value.claim
                    role_arn = mapping_rule.value.role_arn
                    value = mapping_rule.value.value
                }
            }
            type = role_mapping.value.type
        }
    }
    roles = var.roles
}