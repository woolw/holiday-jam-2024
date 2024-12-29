#!/bin/bash

usage() {
    echo "Usage: $0 [-r] | [-d] | [-b]"
    echo "  -[r]un            Run the game"
    echo "  -[d]ebug          Debug the game"
    echo "  -[b]uild          Build the game and output all contents to release folder"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

while getopts "rdb" opt; do
    case ${opt} in
        r)
            echo "RUNNING GAME"
            odin run . -o:speed -out:bin/mac_bin 
            ;;
        d)
            echo "DEBUGGING GAME"
            odin run . -o:speed -out:bin/mac_bin --debug           
            ;;
        b)
            echo "BUILDING GAME"

            odin build . -o:speed -out:bin/mac_bin 
            cp -r assets bin/release 
            cp bin/mac_bin bin/release
            ;;
        ?)
            usage
            ;;
    esac
done