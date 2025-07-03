# terraform-kratos-module

A Terraform module for easy deployment of Ory Kratos.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.37.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map_v1.kratos_config_files](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_deployment_v1.kratos](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_deployment_v1.kratos_courier](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_ingress_v1.kratos_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_job_v1.kratos_migrations](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job_v1) | resource |
| [kubernetes_secret_v1.kratos_config_yaml](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.kratos_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_service_v1.kratos_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [random_password.kratos_cipher_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.kratos_cookie_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [kubernetes_namespace_v1.kratos_ns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/namespace_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_files"></a> [config\_files](#input\_config\_files) | Additional files to be mounted at /etc/kratos, e.g. identity schemas and courier templates | `map(string)` | `{}` | no |
| <a name="input_config_yaml"></a> [config\_yaml](#input\_config\_yaml) | Content of kratos.yaml configuration file | `string` | n/a | yes |
| <a name="input_courier_mode"></a> [courier\_mode](#input\_courier\_mode) | Message courier deployment mode, one of: "disabled", "background", "standalone" | `string` | n/a | yes |
| <a name="input_courier_resources"></a> [courier\_resources](#input\_courier\_resources) | Resource requests and limits for courier Kratos pod | <pre>object({<br/>    requests = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>    limits = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_courier_smtp_connection_uri"></a> [courier\_smtp\_connection\_uri](#input\_courier\_smtp\_connection\_uri) | SMTP connection data and credentials in URI form for email delivery, e.g. smtps://apikey:SG.myapikey@smtp.sendgrid.net:465 | `string` | n/a | yes |
| <a name="input_dsn"></a> [dsn](#input\_dsn) | Data source name, database connection data and credentials in URI form, e.g. postgresql://kratos:correct%20horse%20battery%20staple@postgresd:5432/kratosdb?sslmode=require&max_conns=20&max_idle_conns=4 | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | A list of additional environment variables that will be passed as the `env` block in pods | <pre>list(object({<br/>    name  = string<br/>    value = optional(string)<br/>    value_from = optional(object({<br/>      config_map_key_ref = optional(object({<br/>        optional = bool<br/>        name     = string<br/>        key      = string<br/>      }))<br/>      secret_key_ref = optional(object({<br/>        optional = bool<br/>        name     = string<br/>        key      = string<br/>      }))<br/>      field_ref = optional(object({<br/>        api_version = string<br/>        field_path  = string<br/>      }))<br/>      resource_field_ref = optional(object({<br/>        container_name = string<br/>        divisor        = string<br/>        resource       = string<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_image"></a> [image](#input\_image) | Image repository and version to use for deployment | `string` | `"docker.io/oryd/kratos:v1.0.0"` | no |
| <a name="input_ingress_host"></a> [ingress\_host](#input\_ingress\_host) | Create an ingress to expose public Kratos endpoint under this hostname if provided | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Kubernetes labels to attach to created resources | `map(string)` | `{}` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace to deploy to | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name to used as label and prefix for created resources | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of main Kratos pod replicas, must be a positive integer | `number` | `1` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Resource requests and limits for main Kratos pods | <pre>object({<br/>    requests = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>    limits = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_ingress_url"></a> [external\_ingress\_url](#output\_external\_ingress\_url) | Public URL for connecting to deployed Kratos instance from outside the cluster, if ingress\_host was provided |
| <a name="output_internal_service_url"></a> [internal\_service\_url](#output\_internal\_service\_url) | Cluster-private URLs for connecting to deployed Kratos instance, both public and admin API endpoints |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Name of created Kubernetes service for use with other routing schemes |
