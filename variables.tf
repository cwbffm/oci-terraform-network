variable "compartment_ocid" {
  description = "OCID do compartment existente que receberá a rede."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.compartment\\.", var.compartment_ocid))
    error_message = "Informe um OCID de compartment, começando com ocid1.compartment."
  }
}

variable "region" {
  description = "Região OCI de destino."
  type        = string
  default     = "sa-saopaulo-1"

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "A região deve ser preenchida."
  }
}

variable "config_file_profile" {
  description = "Perfil existente no arquivo local ~/.oci/config."
  type        = string
  default     = "DEFAULT"
}

variable "project_name" {
  description = "Prefixo dos nomes e DNS da VCN: 3 a 15 letras minúsculas ou números, começando por letra."
  type        = string
  default     = "portfolio"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,14}$", var.project_name))
    error_message = "Use 3 a 15 caracteres alfanuméricos minúsculos, começando por uma letra."
  }
}

variable "environment" {
  description = "Ambiente usado nos nomes e nas tags."
  type        = string
  default     = "lab"

  validation {
    condition     = contains(["lab", "dev", "test", "prod"], var.environment)
    error_message = "Use lab, dev, test ou prod."
  }
}

variable "vcn_cidr" {
  description = "Rede IPv4 privada canônica /16; as sub-redes /24 são calculadas automaticamente."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition = try(
      cidrnetmask(var.vcn_cidr) == "255.255.0.0" &&
      var.vcn_cidr == "${cidrhost(var.vcn_cidr, 0)}/16" &&
      can(regex("^(10\\.|172\\.(1[6-9]|2[0-9]|3[01])\\.|192\\.168\\.)", var.vcn_cidr)),
      false
    )
    error_message = "Use um bloco IPv4 privado /16 com endereço de rede, como 10.20.0.0/16."
  }
}

variable "freeform_tags" {
  description = "Tags adicionais. Project, Environment e ManagedBy são definidos pelo projeto."
  type        = map(string)
  default     = {}
}
