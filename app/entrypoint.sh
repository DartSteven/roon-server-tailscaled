#!/bin/bash

# Check if Tailscale should be enabled
if [ "$ENABLE_TAILSCALE" == "enable" ]; then
  echo "Starting Tailscale"
  tailscaled &
  tailscale up --authkey=${TAILSCALE_AUTHKEY} ${TAILSCALE_EXTRA_ARGS}
else
  echo "Tailscale is disabled"
fi

# Determine the Roon package URL based on the ROON_VERSION environment variable
if [ "$ROON_VERSION" == "EarlyAccess" ]; then
  ROON_PACKAGE_URI="https://download.roonlabs.net/builds/earlyaccess/RoonServer_linuxx64.tar.bz2"
else
  ROON_PACKAGE_URI="http://download.roonlabs.com/builds/RoonServer_linuxx64.tar.bz2"
fi

echo "Starting RoonServer with user $(whoami)"

# Install Roon if not present
if [ ! -f /opt/RoonServer/start.sh ]; then
  echo "Downloading Roon Server from ${ROON_PACKAGE_URI}"
  wget --tries=2 -O - ${ROON_PACKAGE_URI} | tar -xvj --overwrite -C /opt
  if [ $? != 0 ]; then
    echo "Error: Unable to install Roon Server."
    exit 1
  fi
fi

echo Verifying Roon installation
/opt/RoonServer/check.sh
retval=$?
if [ ${retval} != 0 ]; then
  echo Verification of Roon installation failed.
  exit ${retval}
fi

# Start Roon
#
# Since we're invoking from a script, we need to
# catch signals to terminate Roon nicely
/opt/RoonServer/start.sh &
roon_start_pid=$!
trap 'kill -INT ${roon_start_pid}' SIGINT SIGQUIT SIGTERM
wait "${roon_start_pid}" # block until Roon terminates
retval=$?
exit ${retval}
