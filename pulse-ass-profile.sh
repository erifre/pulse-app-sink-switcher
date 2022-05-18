#!/usr/bin/env bash

speaker_sink="alsa_output.pci-0000_00_1b.0.analog-stereo"
headset_sink="alsa_output.usb-Creative_Technology_Ltd_SB_X-Fi_Surround_5.1_Pro_00000HaK-00.analog-stereo"

if [ $1 == 'headset' ]; then
    application-sound -s "${headset_sink}" --applicationBin spotify --volume 30
    application-sound -s "${headset_sink}" --application Overwatch --volume 50
elif [ $1 == 'speakers' ]; then
    application-sound -s "${speaker_sink}" --applicationBin spotify --volume 100
    application-sound -s "${speaker_sink}" --application Overwatch --volume 100
else
    echo "Unknown profile"
    exit 1
fi