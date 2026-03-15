#!/bin/sh
if [ "$2" = "init" ]; then
	printf "\nInit script:\n"
	if [ "$1" = "debug" ]; then
		printf "\nDEBUG\n"
	    cmake ../code -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -G Ninja
	else
	    cmake ../code -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -G Ninja
	fi
	cmake --build .
	printf "\nBuild complete:\n"
	printf "\nGenerating System Tables:\n"
	./scripts/mariadb-install-db --srcdir=../code --defaults-file=~/mariadb.cnf --user=root
	printf "\nGenerating System Tables Complete\n"
else
	if [ "$1" = "debug" ]; then
	    printf "\nConfiguring debug build . . .\n"
	    time cmake ../code -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -G Ninja
	else
	    printf "\nConfiguring standard build . . .\n"
	    time cmake ../code -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -G Ninja
	fi
	printf "\nCompiling Build:\n"
	time cmake --build .
	printf "\nCompile Complete\n"
	./sql/mariadbd -V
	printf "\nContainer up for ad-hoc dev purposes . . .\n"
	sleep infinity
fi
