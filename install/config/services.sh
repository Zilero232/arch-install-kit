#!/bin/bash

# System services configuration
# Defines which services should be enabled and started
# 
# Categories:
# - Services to enable at boot
# - Services to start immediately

# Services to enable at boot
ENABLE_SERVICES=(
    "NetworkManager"  
    "bluetooth"       
    "tlp"             
    "cpupower"        
    "sddm"            
)

# Services to start immediately
START_SERVICES=(
    "NetworkManager"
    "bluetooth"
)