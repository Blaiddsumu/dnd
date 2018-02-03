#!/bin/bash

cd /app
bundle install && jekyll build
status=$?

chown -R $(stat -c %u ./build-inner.sh) .

exit $status
