# tfe-workspace-setup
Sample configuration to populate a Terraform Cloud/Enterprise Workspace configuration

Published 1/30/2020 at the requests of HashiCorp webinar participants from https://www.hashicorp.com/webinars/vcs-terraform-cloud-azure-devops-gitlab-github-and-bitbucket

This configuration assumes you already have a Terraform Cloud/Enterprise account created and a workspace already exists.

To authenticate against Terraform Cloud you must have a `.terraformrc` file configured, containing the following:
```
JSON
credentials "app.terraform.io" {
  token = "your-terraform-cloud-token-here"
}```

The token required can be obtained from the User Settings > Tokens section within your Terraform Cloud account

Once you have this configuration, you can simply run a `terraform init` to download the TFE provider, followed by a `terraform plan` and `terraform apply` as normal to create the workspace configuration.

Additional documentation is provided within `main.tf` itself.
