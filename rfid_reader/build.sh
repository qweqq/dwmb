#!/bin/zsh

# fixme

gcc -Wall -o rc522_reader main.c rc522.c rfid.c -lbcm2835
