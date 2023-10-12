#!/bin/bash

echo "##### cimpl test #####"

for i in {1..5}; do
    output=$(./cminus_cimpl "example/test${i}.cm" | diff - "example/test${i}_result")
    if [ -z "$output" ]; then
        echo "test $i 통과"
    else
        echo "<test $i>"
        echo "$output"
    fi
done
