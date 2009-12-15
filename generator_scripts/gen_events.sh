#!/bin/sh
script/destroy scaffold Event

#generate new schema
script/generate scaffold Event \
name:string \
startdate:timestamp \
enddate:timestamp \
description:text \
url:string \
image:string \
street:string \
city:string \
state:string \
zip:integer 



#./script/generate authenticated artist sessions —include-activation —stateful —rspec —skip-migration —skip-routes —old-passwords

#rake db:drop && rake db:create && rake db:migrate

