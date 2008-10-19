#!/bin/bash

set -e

rm -rf raw_data

mkdir raw_data

./retrieve_data.pl

./parse_data.pl
