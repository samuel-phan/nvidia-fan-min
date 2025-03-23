#!/usr/bin/env bash
# Copyright (c) 2021 Samuel Phan
# Licensed under the terms of the MIT License. See LICENSE file in project root for terms.

fan_control=""
FAN_CONTROL_AUTO=0
FAN_CONTROL_MANUAL=1
fan_speed=40
gpu_cmd="nvidia-settings"
sleep_time=1
temperature_threshold=40

get_query() {
    echo "$($gpu_cmd -q "$1")"
}

get_temperature() {
    local temperature=0
    for (( i=0; i<$num_gpus; i++ )) do
        t="$($gpu_cmd -q=[gpu:"$i"]/GPUCoreTemp -t)"
        temperature=$(( temperature > t ? temperature : t ))
    done
    echo $temperature
}

set_fan_control() {
    # $1 can be:
    #   - `0`: disable manual fan control (let NVIDIA drivers control fan)
    #   - `1`: enable manual fan control
    "$gpu_cmd" -a GPUFanControlState="$1"
}

set_fan_speed() {
    # $1 is a percentage (between 0 and 100)
    "$gpu_cmd" -a GPUTargetFanSpeed="$1"
}

# Get the system's GPU configuration
num_fans=$(get_query "fans"); num_fans="${num_fans%* Fan on*}"
if [ -z "$num_fans" ]; then
	echo "No Fans detected"; exit 1
elif [ "${#num_fans}" -gt "2" ]; then
	num_fans="${num_fans%* Fans on*}"
fi
echo "Number of Fans detected: $num_fans"

num_gpus=$(get_query "gpus"); num_gpus="${num_gpus%* GPU on*}"
if [ -z "$num_gpus" ]; then
	echo "No GPUs detected"; exit 1
elif [ "${#num_gpus}" -gt "2" ]; then
	num_gpus="${num_gpus%* GPUs on*}"
fi
echo "Number of GPUs detected: $num_gpus"

# Main loop
while :; do
    temperature=$(get_temperature)
    if (( temperature < temperature_threshold )); then
        if (( fan_control == FAN_CONTROL_AUTO )) || [ -z $fan_control ]; then
            # set manual fan
            (( fan_control = FAN_CONTROL_MANUAL ))
            set_fan_control $fan_control
            set_fan_speed $fan_speed
        fi
    else
        if (( fan_control == FAN_CONTROL_MANUAL )) || [ -z $fan_control ]; then
            # let NVIDIA drivers control fan
            (( fan_control = FAN_CONTROL_AUTO ))
            set_fan_control $fan_control
        fi
    fi
    sleep $sleep_time
done
