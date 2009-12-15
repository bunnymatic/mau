#!/bin/sh
script/destroy scaffold Tag

#generate new schema
script/generate scaffold Tag \
name:string 

