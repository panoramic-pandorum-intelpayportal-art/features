#!/bin/bash

set -e

source dev-container-features-test-lib

check "ninja --version" ninja --version

reportResults
