#!/usr/bin/env sh
# This script is the entry point for Methods 1, 2 or 3 switching at boot
CML=$*

# Add commands to be run before switching here:

## For example Nvidia dGPU + Nvidia eGPU you may need to uncomment the following lines to manually reload the nvidia_drm module
# for n in $(seq 1 30); do
#     sleep 0.1
#     modprobe -r nvidia_drm && modprobe nvidia_drm modeset=1 fbdev=1
#     if [ "$?" = 0 ]; then break; fi
# done

# The script is run here:
all-ways-egpu $CML

# Add commands to be run after Methods 1, 2 or 3 are completed switching here:

