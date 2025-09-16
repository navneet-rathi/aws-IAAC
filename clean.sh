#!/bin/bash
str=$1 
cleaned=${str//\'/} 
echo $cleaned