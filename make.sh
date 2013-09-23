#!/bin/bash

cat templates/map.html | sed -e 's/\.\.\/static/static/g' \
    -e 's/static\/js\/lib\/angular\.js/https:\/\/ajax.googleapis.com\/ajax\/libs\/angularjs\/1.1.4\/angular.min.js/' > index.html
