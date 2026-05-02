#!/bin/bash

if [ "$1" == "" ]; then
  read val
else
  val=$1
fi

echo $((val*2))

