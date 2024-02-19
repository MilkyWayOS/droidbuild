# frozen_string_literal: true

def execute(cmdline)
  info "Execute: #{cmdline}"
  result = system cmdline
  unless result
    error "Failed to execute command"
    exit -1
  end
end