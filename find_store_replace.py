#   _______        _                           _             _       _   _             
#  |__   __|      | |                         (_)           | |     | | (_)            
#     | | _____  _| |_   _ __ ___   __ _ _ __  _ _ __  _   _| | __ _| |_ _  ___  _ __  
#     | |/ _ \ \/ / __| | '_ ` _ \ / _` | '_ \| | '_ \| | | | |/ _` | __| |/ _ \| '_ \ 
#     | |  __/>  <| |_  | | | | | | (_| | | | | | |_) | |_| | | (_| | |_| | (_) | | | |
#     |_|\___/_/\_\\__| |_| |_| |_|\__,_|_| |_|_| .__/ \__,_|_|\__,_|\__|_|\___/|_| |_|
#                                               | |                                    
#                                               |_|                                    
#!/usr/bin/env python3

import re
import sys
from collections import Counter

# https://stackoverflow.com/questions/17140886/how-to-search-and-replace-text-in-a-file
def replace_ip_in_file(list_ip, file_to_use):
  # Read in the file
  with open(file_to_use, 'r') as file :
    filedata = file.read()

  # Replace the target string
  for ip in list_ip:
    filedata = filedata.replace(ip, 'demoOO')

  # Write the file out again
  with open(file_to_use, 'w') as file:
    file.write(filedata)

  file.close()

def count_duplicates(list_ip):
  duplicates_dict = Counter(list_ip)
  
  return duplicates_dict

# Function to regex all IPs from the files saved in the lines list
def grep_ip(lines):
  # Prepare the regex
  pattern = re.compile(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})')
  # initializing the list object
  lst=[]
  
  # For each line, checking if the pattern is present and, if yes, put it in lst
  for line in lines:
    match = pattern.search(line)[0]
    lst.append(match)
  
  # Remove duplicate 
  # From https://stackoverflow.com/questions/8200342/removing-duplicate-strings-from-a-list-in-python
  # list_ip = list(set(lst))

  return lst

# Save the file into a list and count number of lines
def file_nbr_lines(file_to_use):
  lines = []

  # Read and copy each lines into the list created above
  with open(file_to_use, "r") as file:
    lines = file.readlines()
  
  # How much line there's in the file
  nbr_lines = len(lines)
  # Close file to avoid issue
  file.close()

  return nbr_lines, lines

# Remove x lines to have a file size that will allow specific computer to run the script without issues
def remove_lines(lines, file_to_use):
  # We open the same file as writable to be able to modify it
  with open(file_to_use, 'w') as file:
    # iterate each line
    for number, line in enumerate(lines):
      # We want to keep the first 10000 lines, if it's under this number
      # We re-write the file with the line from the list
      if number < 10000:
        fp.write(line)
  
  file.close()

def main():
  print(sys.argv)
  # Second argument is the file we want to work with
  file_to_use = sys.argv[1]
  # Get the file and it's number of lines
  nbr_lines, lines = file_nbr_lines(file_to_use)

  # Sometimes there can be issue with BIG files and disk space
  # To avoid issue, we reduce file by removing lines
  # Check if one argument is given and if it's named opti-file
  if len(sys.argv) == 3:
    if sys.argv[2] == "--opti-file":
      # To avoid issue with disk space, some lines are removed 
      if nbr_lines > 50000:
        print("above 50k")
        remove_lines(lines, file_to_use)
    else:
      print("only flag available is --opti-file")
      exit(1) 
  
  # Retrieve all IPs from the file
  list_ip = grep_ip(lines)

  # Count duplicated
  duplicates_dict = count_duplicates(list_ip)

  # Rewrite the ip with a keyword, here demo
  replace_ip_in_file(list_ip, file_to_use)

if __name__ == '__main__':
  main()