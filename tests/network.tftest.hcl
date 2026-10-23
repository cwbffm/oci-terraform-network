mock_provider "oci" {}

variables {
  compartment_ocid = "ocid1.compartment.oc1..example"
}

run "private_network_defaults" {
  command = plan

  assert {
    condition     = length(oci_core_subnet.private) == 2
    error_message = "O exemplo deve criar exatamente duas sub-redes."
  }

  assert {
    condition     = oci_core_subnet.private["app"].cidr_block == "10.20.1.0/24" && oci_core_subnet.private["management"].cidr_block == "10.20.2.0/24"
    error_message = "As sub-redes app e management devem usar os blocos /24 previstos."
  }

  assert {
    condition     = alltrue([for subnet in oci_core_subnet.private : subnet.prohibit_public_ip_on_vnic])
    error_message = "As sub-redes devem impedir a atribuição de IP público."
  }

  assert {
    condition     = length(oci_core_security_list.private.ingress_security_rules) == 0 && length(oci_core_security_list.private.egress_security_rules) == 0
    error_message = "A lista dedicada deve começar sem liberações de tráfego."
  }

  assert {
    condition     = length(oci_core_route_table.private.route_rules) == 0
    error_message = "A tabela privada deve começar sem rotas para gateways."
  }
}

run "custom_network_and_tags" {
  command = plan

  variables {
    vcn_cidr = "172.20.0.0/16"
    freeform_tags = {
      CostCenter = "lab"
      ManagedBy  = "manual"
    }
  }

  assert {
    condition     = oci_core_subnet.private["app"].cidr_block == "172.20.1.0/24"
    error_message = "As sub-redes devem acompanhar o bloco privado informado."
  }

  assert {
    condition     = oci_core_vcn.network.freeform_tags["CostCenter"] == "lab" && oci_core_vcn.network.freeform_tags["ManagedBy"] == "Terraform"
    error_message = "As tags adicionais devem ser preservadas e ManagedBy deve identificar o Terraform."
  }
}

run "reject_public_cidr" {
  command = plan

  variables {
    vcn_cidr = "8.8.0.0/16"
  }

  expect_failures = [var.vcn_cidr]
}

run "reject_noncanonical_cidr" {
  command = plan

  variables {
    vcn_cidr = "10.20.1.0/16"
  }

  expect_failures = [var.vcn_cidr]
}
