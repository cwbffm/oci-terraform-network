output "vcn_id" {
  description = "OCID da VCN criada."
  value       = oci_core_vcn.network.id
}

output "subnets" {
  description = "Identificadores e redes das sub-redes privadas."
  value = {
    for name, subnet in oci_core_subnet.private : name => {
      id         = subnet.id
      cidr_block = subnet.cidr_block
    }
  }
}

output "route_table_id" {
  description = "OCID da tabela sem rotas para gateways."
  value       = oci_core_route_table.private.id
}

output "security_list_id" {
  description = "OCID da lista dedicada, inicialmente sem regras de liberação."
  value       = oci_core_security_list.private.id
}
