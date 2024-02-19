#!/usr/bin/env bash

fail(){
  echo "Failed"
  exit 255
}

echo "Unpacking droidbuildx to buildroot..."
mkdir -p /opt/droid/buildroot/.repo || fail
mkdir -p /opt/droid/buildroot/.repo/local_manifests || fail
mkdir -p /opt/droid/buildroot/droidbuild/ || fail
cp -r /opt/droid/lib/modules /opt/droid/buildroot/droidbuild/modules || fail
cp -r /opt/droid/config/manifests/* /opt/droid/buildroot/.repo/local_manifests/ || fail
cp /opt/droid/config/.droidbuildx.yaml /opt/droid/buildroot/ || fail
echo "Done"