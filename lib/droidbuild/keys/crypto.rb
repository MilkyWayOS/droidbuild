# frozen_string_literal: true
require 'meta'
require 'log'
require 'droidlib'
require 'config'

def generate_keys
  change_dir "/tmp"
  if Dir.exist?("android-certs")
    warning "android-certs directory exists already. Removing it."
    Dir.rmdir("android-certs")
  end
  Dir.mkdir("android-certs")
  change_dir "/tmp/android-certs"
  subject = Configuration.get_value("keys.subject")
  KEY_SET.each do |keyname|
    info "Generating key #{keyname}"
    system "#{BASEDIR}/development/tools/make_key #{keyname} '#{subject}';"
  end
  KEY_SET.each do |keyname|
    info "Converting key #{keyname}"
    execute "openssl rsa -inform DER -in #{keyname}.pk8 -out #{keyname}.key"
  end
  change_dir "/tmp"
  info "Creating encrypting key bundle"
  execute "zip -r certbundle.zip android-certs"
  execute "scrypt enc certbundle.zip > certbundle.zip.sc"
  execute "mv certbundle.zip.sc #{KEYSTORE_DIR}"
  execute "srm -r android-certs certbundle.zip"
  success "Finished generating keys"
  exit_dir
end

def open_keys
  Dir.mkdir(OPEN_KEYS_DIR) unless Dir.exist?(OPEN_KEYS_DIR)
  if Dir.exist? "#{OPEN_KEYS_DIR}/android-certs"
    warning "Keys seem to be opened, doing nothing"
    return
  end
  require_file "#{KEYSTORE_DIR}/certbundle.zip.sc"
  result = false
  until result
    result = system("scrypt dec #{KEYSTORE_DIR}/certbundle.zip.sc > #{OPEN_KEYS_DIR}/certbundle.zip")
  end
  change_dir OPEN_KEYS_DIR
  execute "unzip certbundle.zip"
  execute "srm certbundle.zip"
  exit_dir
  success "Opened keys successfully"
end

def close_keys
  unless Dir.exist? OPEN_KEYS_DIR
    error "Keys are not opened"
    return
  end
  execute "srm -r #{OPEN_KEYS_DIR}"
end