#!/bin/bash
FAIL_FAST=1
INSTALL=1
for arg in "$@" ; do
  shift
  case "$arg" in 
    "--no-fail") FAIL_FAST=0;;
    "--no-install") INSTALL=0;;
    *) ;;
  esac
done

mkdir out

for d in */ ; do
  if [ ! -f "./$d/CMakeLists.txt" ] ; then
    continue
  fi
  echo Building $d...
  cmake -S ./$d -B ./out/$d -DCMAKE_INSTALL_PREFIX:PATH=/usr
  if [[ $? != 0 && $FAIL_FAST == 1 ]] ; then
    echo "Failed to generate config for $d, exiting."
    exit 1
  fi
  make -C ./out/$d
  if [[ $? != 0 && $FAIL_FAST == 1 ]] ; then
    echo "Failed to build $d, exiting."
    exit 2
  fi
  if [[ $INSTALL == 1 ]] ; then
    sudo make -C ./out/$d install
    if [[ $? != 0 && $FAIL_FAST == 1 ]] ; then
      echo "Failed to install $d, exiting."
      exit 3
    fi
  fi
done
