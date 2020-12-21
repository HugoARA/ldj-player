#!/bin/bash

# set path to script location
cd `dirname $0`

if [[ -d "$1" ]]; then
	Path="`realpath $1`/.metadata/.plugins/org.eclipse.debug.core/.launches"
	mkdir -p $Path
	cp -vi *.launch $Path
else
	echo "Please specify your eclipse workspace directory!"
	echo "	ex: $0 <directory>"
fi

