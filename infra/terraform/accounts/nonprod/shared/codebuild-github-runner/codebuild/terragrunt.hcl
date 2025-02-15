include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals
}

terraform {
  source = "../../../../../modules/codebuild-gh-runner"
}

dependency "codebuild_role" {
  config_path = "../codebuild_role"

  mock_outputs = {
    role_arn = "arn:aws:iam::123456789012:role/mock-codebuild-role"
  }
}

# Using IaC to do the CodeStar Connectio requires manual approval, so it's commented out for now
# dependency "codestar_connection" {
#   config_path = "../../codestar-connection"

#   mock_outputs = {
#     connection_arn  = "arn:aws:codestar-connections:us-west-2:123456789012:connection/mock-connection"
#     connection_name = "github-cybercussion"
#   }
# }

inputs = {
  project_name     = "github-runner"
  #account_name     = local.common.environment (needed for labeling concept)
  service_role_arn = dependency.codebuild_role.outputs.role_arn
  github_repo      = local.common.location
  connection_arn   = local.common.connection_arn
  connection_name  = local.common.connection_name
  compute_type     = local.common.compute_type
  image            = local.common.image

  # Tags for resources
  tags = local.common.tags
}