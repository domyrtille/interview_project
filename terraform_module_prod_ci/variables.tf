#   _____  _____   ____  _____          _____ _____   _______ ______   __  __  ____  _____  _    _ _      ______ 
#  |  __ \|  __ \ / __ \|  __ \        / ____|_   _| |__   __|  ____| |  \/  |/ __ \|  __ \| |  | | |    |  ____|
#  | |__) | |__) | |  | | |  | |______| |      | |      | |  | |__    | \  / | |  | | |  | | |  | | |    | |__   
#  |  ___/|  _  /| |  | | |  | |______| |      | |      | |  |  __|   | |\/| | |  | | |  | | |  | | |    |  __|  
#  | |    | | \ \| |__| | |__| |      | |____ _| |_     | |  | |      | |  | | |__| | |__| | |__| | |____| |____ 
#  |_|    |_|  \_\\____/|_____/        \_____|_____|    |_|  |_|      |_|  |_|\____/|_____/ \____/|______|______|
#

# Defines a variable for the module
variable "project" {
  type    = string
  description = "Project's name"
  default = "prod_ci"
}

variable "domain" {
  type        = string
  description = "Domain of the project"
  default = "interview.local"
}

variable "prod_ci_user" {
  type        = string
  description = "Name of the user"
  default = "prod_ci_user"
}

variable "prod_ci_group" {
  type        = string
  description = "Name of the Group"
  default = "prod_ci_group"
}

variable "aws_account_id" {
  type        = string
  description = "id of interviewer account"
  default = "452618540275"
}