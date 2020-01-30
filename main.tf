#Sample Config to set up key Workspace Variables in a pre-existing Terraform Cloud/Enterprise Workspace
#Originally created Jan 30 2020 by Jon Schulman, HashiCorp
#This is a quick sample only and has either dummy or redacted values, be sure to replace with your own
#full doc available at https://www.terraform.io/docs/providers/tfe/r/variable.html

#require the TFE provider
provider "tfe" {

}

#because we are assuming a pre-existing workspace, use a datasource to get details on it
#if you want to create the workspace on the fly as part of this config, that's 
#fine too - but you'll want to use a resource object instead here

data "tfe_workspace" "tfe-wrapper-test" {
  name         = "my-workspace-name"
  organization = "my-organization-name"
}

#creating your first resource here, for a private key. because this key is sensitive
#you definitely don't want to store it in git! also, it's been marked as sensitive=true to
#mask its value in the UI

#additionally, it's dummied out so github's token scanner doesn't catch and block the file
#basically, just dump your whole key in using HEREDOC format (EOT as tag in this case)

resource "tfe_variable" "aws_key" {
  key          = "private_key"
  value        = <<EOT
-----FULL PRIVATE KEY BLOCK HERE-----
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341
abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd1=
-----YOUR PRIVATE KEY ENDS-----
EOT
  category     = "terraform"
  sensitive    = "true"
  workspace_id = data.tfe_workspace.tfe-wrapper-test.id

}

#another resource for public key, also obfuscated here - the public key can fit on a single line,
#no need for HEREDOC in this case. also marked as sensitive.
resource "tfe_variable" "public_key" {
  key          = "public_key"
  value        = "key-format abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341abcdabcdabcd112341234abcdabcdabcdabcdabcd112341234abcdabcdabcdabcdabcd112341"
  category     = "terraform"
  sensitive    = "true"
  workspace_id = data.tfe_workspace.tfe-wrapper-test.id

}

#this resource populates a slack webhook URL, used by another module in the workspace later
resource "tfe_variable" "slack_webhook_url" {
  key          = "slack_webhook_url"
  value        = "https://your.slack.webhook.URL.goes.here"
  sensitive    = "true"
  category     = "terraform"
  workspace_id = data.tfe_workspace.tfe-wrapper-test.id

}

#now changing it up a bit to an environment variable, these live in the "shell" as opposed to the teraform execution itself
#this is your AWS IAM secret
resource "tfe_variable" "aws_secret_access_key" {
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = "YOUR_AWS_KEY_GOES_HERE"
  sensitive    = "true"
  category     = "env"
  workspace_id = data.tfe_workspace.tfe-wrapper-test.id

}

#this sets your AWS IAM key ID
resource "tfe_variable" "aws_access_key_id" {
  key          = "AWS_ACCESS_KEY_ID"
  value        = "YOUR_AWS_KEY_ID_GOES_HERE"
  sensitive    = "true"
  category     = "env"
  workspace_id = data.tfe_workspace.tfe-wrapper-test.id

}

#set the AWS default region
resource "tfe_variable" "aws_default_region" {
  key          = "AWS_DEFAULT_REGION"
  value        = "us-east-1"
  category     = "env"
  workspace_id = data.tfe_workspace.tfe-wrapper-test.id

}

#allow for deletion of resources; without this flag set to 1 TFC/TFE will block any attempts to queue a destroy plan
resource "tfe_variable" "confirm_destroy" {
  key          = "CONFIRM_DESTROY"
  value        = "1"
  category     = "env"
  workspace_id = data.tfe_workspace.tfe-wrapper-test.id

}

#create a slack notification that automatically sends output to the webhook specified whenever a run is 
#created, pending action, or errored. full documentation of this resource type is at
#https://www.terraform.io/docs/providers/tfe/r/notification_configuration.html

resource "tfe_notification_configuration" "slack" {
  name                      = "Notify in Slack"
  enabled                   = true
  destination_type          = "slack"
  triggers                  = ["run:created", "run:needs_attention", "run:errored"]
  url                       = "https://your.slack.webhook.URL.goes.here"
  workspace_external_id     = data.tfe_workspace.tfe-wrapper-test.external_id
}

#this is just a nice to have - every workspace in TFC/TFE can have its own underlying terraform version
#to allow for compatibility, etc. however a new workspace is always created at the current newest version available
#so outputting it here lets you see what you're working with

output "workspace_tf_version" {
  value = "${data.tfe_workspace.tfe-wrapper-test.terraform_version}"
}