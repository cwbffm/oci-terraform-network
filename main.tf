locals {
  name = "${var.project_name}-${var.environment}"

  tags = merge(var.freeform_tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })

  subnets = {
    app = {
      netnum    = 1
      dns_label = "app"
    }
    management = {
      netnum    = 2
      dns_label = "mgmt"
    }
  }
}

resource "oci_core_vcn" "network" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.name}-vcn"
  dns_label      = var.project_name
  cidr_blocks    = [var.vcn_cidr]
  freeform_tags  = local.tags
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.network.id
  display_name   = "${local.name}-private-rt"
  freeform_tags  = local.tags

  # A ausência de blocos route_rules mantém a tabela sem rotas para gateways.
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.network.id
  display_name   = "${local.name}-private-sl"
  freeform_tags  = local.tags

  # Sem blocos de regras, esta lista dedicada não libera entrada nem saída.
}

resource "oci_core_subnet" "private" {
  for_each = local.subnets

  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.network.id
  display_name               = "${local.name}-${each.key}"
  dns_label                  = each.value.dns_label
  cidr_block                 = cidrsubnet(var.vcn_cidr, 8, each.value.netnum)
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  freeform_tags              = local.tags
}
