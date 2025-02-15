include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../../modules/iam_role"
}

locals {
  common = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals
}

inputs = {
  role_name = "${local.common.environment}-codebuild-github-runner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  inline_policies = {
    CodeBuildGitHubRunnerPolicy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "codebuild:StartBuild",
            "codebuild:BatchGetBuilds",
            "codebuild:ListBuilds",
            "codebuild:BatchGetProjects"
          ],
          Resource = "*"
        },
        {
          Effect = "Allow",
          Action = [
            "codestar-connections:UseConnection",
            "codestar-connections:GetConnection",
            "codestar-connections:GetConnectionToken",
            "codeconnections:GetConnection",
            "codeconnections:GetConnectionToken"
          ],
          Resource = local.common.connection_arn
        },
        {
          Effect = "Allow",
          Action = [
            "codebuild:CreateWebhook",
            "codebuild:UpdateWebhook",
            "codebuild:DeleteWebhook"
          ],
          Resource = "arn:aws:codebuild:${local.common.aws_region}:${local.common.account_id}:project/*"
        },
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Resource = "arn:aws:logs:${local.common.aws_region}:${local.common.account_id}:log-group:/aws/codebuild/*"
        },
        {
          Effect = "Allow",
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
          ],
          Resource = "arn:aws:s3:::codepipeline-${local.common.aws_region}-*"
        },
        {
          Effect = "Allow",
          Action = [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases",
            "codebuild:BatchPutCodeCoverages"
          ],
          Resource = "arn:aws:codebuild:${local.common.aws_region}:${local.common.account_id}:report-group/*"
        },
        {
          Effect = "Allow",
          Action = [
            "iam:PassRole"
          ],
          Resource = "arn:aws:iam::${local.common.account_id}:role/${local.common.environment}-*",
          Condition = {
            "StringEqualsIfExists" = {
              "iam:PassedToService" = "codebuild.amazonaws.com"
            }
          }
        },
        {
          Effect = "Allow",
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters"
          ],
          Resource = "arn:aws:ssm:${local.common.aws_region}:${local.common.account_id}:parameter/creds/*"
        }
      ]
    })
  }

  managed_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]

  tags = local.common.tags
}