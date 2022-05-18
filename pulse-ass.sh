#!/usr/bin/env bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -a|--application)
            APPLICATION="$2"
            shift
            shift
        ;;
        -b|--applicationBin)
            APPLICATION_BIN="$2"
            shift
            shift
        ;;
        -s|--sink)
            SINK="$2"
            shift
            shift
        ;;
        -v|--volume)
            VOLUME="$2"
            shift
            shift
        ;;
        --install)
            INSTALL=1
            shift
            shift
        ;;
        *)    # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ ! -z $INSTALL ]; then
    echo "Installing into ~/.local/bin"
    mkdir -p "~/.local/bin"

    SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

    filenames=( "pulse-ass.sh" "pulse-ass-profile.sh" )

    for i in "${filenames[@]}"
    do
        :
        if [ ! -L "${SCRIPTPATH}/${i}" ] && [ -f "${SCRIPTPATH}/${i}" ]; then
            ln -sf "${SCRIPTPATH}/${i}" "$HOME/.local/bin/${i}"
            echo "* Linked ${i} to ~/.local/bin/${i}"
        fi
    done
fi

function findInputSink {

    lines=$(pactl list sink-inputs)


    echo "$lines".$'\n' | while read -r line ; do

        if [ -z $index ]; then
            index=$(echo $line | grep -oP 'Sink Input #\K[^$]+')
        fi
        if [ -z $name ]; then
            name=$(echo $line | grep -oP 'application.name = "\K[^"]+')
        fi
        if [ -z $binary ]; then
            binary=$(echo $line | grep -oP 'application.process.binary = "\K[^"]+')
        fi

        if [ "${line-}" = '' ];
        then

            if [ ! -z $APPLICATION ] && [ $APPLICATION = $name ]; then
                echo "${index}"
                elif [ ! -z $APPLICATION_BIN ] && [ $APPLICATION_BIN = $binary ]; then
                echo "${index}"
            fi

            # Reset sink data
            index=
            name=
            binary=
        fi

    done
}

function findSink {

    lines=$(pactl list sinks)

    echo "$lines".$'\n' | while read -r line ; do

        if [ -z $index ]; then
            index=$(echo $line | grep -oP 'Sink #\K[^$]+')
        fi
        if [ -z $name ]; then
            name=$(echo $line | grep -oP 'Name: \K[^$]+')
        fi

        if [ "${line-}" = '' ];
        then

            if [ ! -z $SINK ] && [ $SINK = $name ]; then
                echo "${index}"
            fi

            # Reset sink data
            index=
            name=
        fi

    done
}

findInputSink | while read -r input ; do

    if [ ! -z $SINK ]; then
        findSink | while read -r sink ; do
            pactl move-sink-input $input $sink
        done
    fi

    if [ ! -z $VOLUME ]; then
        volume=$(echo "(65536 * (${VOLUME} / 100)) / 1" | bc -l | xargs printf "%.0f")
        pactl set-sink-input-volume $input $volume
    fi

done