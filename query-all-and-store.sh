#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
source ./query.sh
query-all-and-store-in-show-episodes-dir
