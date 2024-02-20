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
end