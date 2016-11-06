#!/bin/bash

DIR=/home/ec2-user/tv-guide
cd $DIR
source ./query.sh
query-all-and-store-in-show-episodes-dir
