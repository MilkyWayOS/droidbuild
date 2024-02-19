# frozen_string_literal: true

BOLD = `tput bold`
NORMAL = `tput sgr0`
RED = `tput setaf 1`
GREEN=`tput setaf 2`
BLUE=`tput setaf 4`
YELLOW = `tput setaf 11`

def info(*args)
  print("#{BOLD}#{BLUE}=> #{NORMAL}", *args)
  print("\n")
end

def warning(*args)
  print("#{BOLD}#{YELLOW}=> #{NORMAL}", *args)
  print("\n")
end

def error(*args)
  print("#{BOLD}#{RED}==> #{NORMAL}", *args)
  print("\n")
end

def success(*args)
  print("#{BOLD}#{GREEN}==> #{NORMAL}", *args)
  print("\n")
end
