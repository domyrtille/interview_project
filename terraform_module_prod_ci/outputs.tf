#   _____  _____   ____  _____          _____ _____   _______ ______   __  __  ____  _____  _    _ _      ______ 
#  |  __ \|  __ \ / __ \|  __ \        / ____|_   _| |__   __|  ____| |  \/  |/ __ \|  __ \| |  | | |    |  ____|
#  | |__) | |__) | |  | | |  | |______| |      | |      | |  | |__    | \  / | |  | | |  | | |  | | |    | |__   
#  |  ___/|  _  /| |  | | |  | |______| |      | |      | |  |  __|   | |\/| | |  | | |  | | |  | | |    |  __|  
#  | |    | | \ \| |__| | |__| |      | |____ _| |_     | |  | |      | |  | | |__| | |__| | |__| | |____| |____ 
#  |_|    |_|  \_\\____/|_____/        \_____|_____|    |_|  |_|      |_|  |_|\____/|_____/ \____/|______|______|
#

output "password" {
  # Run this command to show the password:
  # terraform output password | base64 --decode | gpg --decrypt.
  value = aws_iam_user_login_profile.prod_ci_user_login.encrypted_password
}