#!/bin/bash

echo "##### parser test #####"

for i in {1..2}; do
    output=$(./cminus_parser "example/test.${i}.txt" | diff - "example/result.${i}.txt")
    if [ -z "$output" ]; then
        echo "==============>test $i 통과"
    else
        echo "----------------------------------<test $i>----------------------------------"
        echo "$output"
    fi
done
