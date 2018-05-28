#!/usr/bin/env bash

find . -name '*.rb' -print0 | xargs -0 perl -pi -e 's/[^\S\r\n]+$//'
find . -name '*.slim' -print0 | xargs -0 perl -pi -e 's/[^\S\r\n]+$//'
find . -name '*.js' -print0 | xargs -0 perl -pi -e 's/[^\S\r\n]+$//'
find . -name '*.coffee' -print0 | xargs -0 perl -pi -e 's/[^\S\r\n]+$//'
find . -name '*.builder' -print0 | xargs -0 perl -pi -e 's/[^\S\r\n]+$//'
find . -name '*.rake' -print0 | xargs -0 perl -pi -e 's/[^\S\r\n]+$//'
find . -name 'Gemfile*' -print0 | xargs -0 perl -pi -e 's/[^\S\r\n]+$//'
