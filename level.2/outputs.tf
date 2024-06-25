output "oidc_url" {
    description = "OIDC URL"
    value       = replace("${module.eks.cluster_oidc_issuer_url}", "https://", "")
}
