#!/bin/bash

cp application.py deploy
cp static/css/*.css deploy/static/css
cp -r static/css/lib deploy/static/css
cp static/js/*.js deploy/static/js
cp -r static/js/lib deploy/static/js
cp -r static/js/data deploy/static/js
cp -r templates/*.html deploy/templates

