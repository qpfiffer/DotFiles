#!/bin/bash -e

. ./base.sh
APP_DIR=$(pwd)/../..

run_container 'postgres'

./self-deploy.sh

