#   _____  _____   ____  _____          _____ _____   _______ ______   __  __  ____  _____  _    _ _      ______ 
#  |  __ \|  __ \ / __ \|  __ \        / ____|_   _| |__   __|  ____| |  \/  |/ __ \|  __ \| |  | | |    |  ____|
#  | |__) | |__) | |  | | |  | |______| |      | |      | |  | |__    | \  / | |  | | |  | | |  | | |    | |__   
#  |  ___/|  _  /| |  | | |  | |______| |      | |      | |  |  __|   | |\/| | |  | | |  | | |  | | |    |  __|  
#  | |    | | \ \| |__| | |__| |      | |____ _| |_     | |  | |      | |  | | |__| | |__| | |__| | |____| |____ 
#  |_|    |_|  \_\\____/|_____/        \_____|_____|    |_|  |_|      |_|  |_|\____/|_____/ \____/|______|______|
#

#################
#      AWS      #
#################
# Create a user named prod_ci_user
resource "aws_iam_user" "prod_ci_user" {
  name = var.prod_ci_user
}

# Create a group named prod_ci_group
resource "aws_iam_group" "prod_ci_group" {
  name = var.prod_ci_group
}

# This will allow to add members to the group created above
resource "aws_iam_group_membership" "prod_ci_group_members" {
  name = "prod_ci_group_members"

  users = [
    aws_iam_user.prod_ci_user.name
  ]

  group = aws_iam_group.prod_ci_group.name
}

# We can use by user/env generated pgp key or keybase service
# Generated pgp could be better since we don't rely on external services
# Based on https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile
resource "aws_iam_user_login_profile" "prod_ci_user_login" {
  user    = aws_iam_user.prod_ci_user.name
  # For readabilty purposes, pgp_key value has been reduced
  pgp_key = "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"
  # Allow user to change the password in case the one created above as been shared in public for easy of use
  password_reset_required = true
}

# Create a policy that doesn't grant any permission and can be assumed by user in same account
# As per https://learn.hashicorp.com/tutorials/terraform/aws-iam-policy?in=terraform/aws
# Writing your policy with this data source makes applying policies to your AWS resources more flexible.
# For example: Terraform checks if there is errors or formats issues
data "aws_iam_policy_document" "prod_ci_no_permission" {  
  statement {   
    actions   = ["*"]
    resources = ["*"]
    effect = "Deny"  
  }
}


# Create a policy allowing user of the same account to assume above role
data "aws_iam_policy_document" "prod_ci_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
    }
  }
}

# Step 1: Create a role that can be assumed by user in the same account
# Using aws_iam_policy_document for better control and checks
resource "aws_iam_role" "prod_ci_role" {
  name               = "prod_ci_role"
  assume_role_policy = data.aws_iam_policy_document.prod_ci_assume_role.json
}

# Create a policy to let user/entities assume the role prod_ci_role
data "aws_iam_policy_document" "prod_ci_group_iam_policy" {
    statement {
        actions = ["sts:AssumeRole"]
        effect = "Allow"
        resources = [aws_iam_role.prod_ci_role.arn]
    }
}

# Attach the policy created above to the group prod_ci_group
resource "aws_iam_group_policy" "prod_ci_iam_group_policy" {
    name = "prod_ci_iam_group_policy"
    group = aws_iam_group.prod_ci_group.id
    policy = data.aws_iam_policy_document.prod_ci_group_iam_policy.json
}

#################