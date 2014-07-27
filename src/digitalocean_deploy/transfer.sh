#!/bin/bash

tar cfz deploy.tar.gz deploy
scp deploy.tar.gz root@198.199.98.183:/root
ssh root@198.199.98.183 /root/deploy.sh
