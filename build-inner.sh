#!/bin/bash

cd /app
bundle install &&\
  jekyll build &&\
  chown -R $(stat -c %u ./build.sh) .
