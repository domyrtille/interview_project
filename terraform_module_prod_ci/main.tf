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
  pgp_key = "mQINBFv1K+cBEADfxbnUhLQeIdMiTRezVBEjNLdhI1gMz1hvx6z4bkRqitEv7eVNM="
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
