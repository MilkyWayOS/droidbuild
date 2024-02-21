# frozen_string_literal: true
VERSION = "2.0-mentha-alpha1"
CODENAME = "mentha"
DOCKER_TAG = "droidbuild:latest"

# Global variables
BASEDIR = "#{`pwd`}".strip
## Arrays of keys to generate
KEY_SET = %w[releasekey cyngn-app media
            platform shared media networkstack
            testkey sdk_sandbox bluetooth testcert
            verity]
## Where to store open keys
OPEN_KEYS_DIR = "#{BASEDIR}/.keys/"
## Where to store encrypted keys
KEYSTORE_DIR = "#{BASEDIR}/out_dir"
## Name of modification(for OTA naming)
MODIFICATION_NAME = "MilkyWayOS"
## Output directory
OUT_DIR = "#{BASEDIR}/out_dir"