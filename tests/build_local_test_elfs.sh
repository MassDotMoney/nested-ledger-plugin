#!/bin/bash

# check system
if [ "$(uname)" == "Darwin" ]
then
	echo "Please build on Docker"
	exit 1
fi

### Variables

# FILL THESE WITH YOUR OWN SDKs PATHS and APP-ETHEREUM's ROOT
NANOS_SDK=$NANOS_SDK
NANOX_SDK=$NANOX_SDK
APP_ETHEREUM=$APP_ETHEREUM
APP_ETHEREUM="/plugin_dev/app-ethereum"

###	Functions

# echo "*Building elfs for Nano S..."

function build_nanos_plugin() {
	echo "**Building app-plugin for Nano S..."
	make clean BOLOS_SDK=$NANOS_SDK
	make -j DEBUG=1 BOLOS_SDK=$NANOS_SDK ALLOW_DATA=1
	cp bin/app.elf "tests/elfs/plugin_nanos.elf"
}

function build_nanos_appeth() {
	echo "**Building app-ethereum for Nano S..."
	cd $APP_ETHEREUM
	make clean BOLOS_SDK=$NANOS_SDK
	make -j DEBUG=1 BYPASS_SIGNATURES=1 BOLOS_SDK=$NANOS_SDK CHAIN=ethereum
	cd -
	cp "${APP_ETHEREUM}/bin/app.elf" "tests/elfs/ethereum_nanos.elf"
}

# echo "*Building elfs for Nano X..."

function build_nanox_plugin() {
	echo "**Building plugin for Nano X..."
	make clean BOLOS_SDK=$NANOX_SDK
	make -j DEBUG=1 BOLOS_SDK=$NANOX_SDK
	cp bin/app.elf "tests/elfs/plugin_nanox.elf"
}

function build_nanox_appeth() {
	echo "**Building app-ethereum for Nano X..."
	cd $APP_ETHEREUM
	make clean BOLOS_SDK=$NANOX_SDK
	make -j DEBUG=1 BYPASS_SIGNATURES=1 BOLOS_SDK=$NANOX_SDK CHAIN=ethereum
	cd -
	cp "${APP_ETHEREUM}/bin/app.elf" "tests/elfs/ethereum_nanox.elf"
}

### Exec

# create elfs folder if it doesn't exist
mkdir -p elfs

# move to repo's root to build apps
cd ..

if [ "$1" == "" ]
then
        echo "plugin s"
				build_nanos_plugin
elif [ "$1" == "eth"  ]
then
        echo "app-eth S"
				build_nanos_appeth
elif [ "$1" == "s"  ]
then
        echo "plugin S + app-eth S"
				build_nanos_plugin
				build_nanos_appeth
elif [ "$1" == "x"  ]
then
        echo "plugin X + app-eth X"
				build_nanox_plugin
				build_nanox_appeth
elif [ "$1" == "all"  ]
then
        echo "plugin S+X + app-eth S+X"
				build_nanos_plugin
				build_nanos_appeth
				build_nanox_plugin
				build_nanox_appeth
else
printf "wrong args:
use no args for [S]plugin,
use 'eth' for [S]app-eth,
use 's' for [S]plugin + [S]app-eth,
use 'all' for building all elfs\n"
fi

echo "done"
