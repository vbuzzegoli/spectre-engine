#!/bin/bash

# Custom prints using colors

if [ $1 = "primary" ]; then
  echo -e "\033[1;33m$2\033[0m"
elif [ $1 = "secondary" ]; then
  echo -e "\n\033[0;34m$2\033[0m\n"
elif [ $1 = "tertiary" ]; then
  echo -e "\033[0;36m$2\033[0m"
elif [ $1 = "neutral" ]; then
  echo -e $2 
elif [ $1 = "info" ]; then
  echo -e "\033[2;37m$2\033[0m"
elif [ $1 = "error" ]; then
  echo -e "\n\033[0;31m$2\033[0m\n"
elif [ $1 = "success" ]; then
  echo -e "\n\033[0;32m$2\033[0m\n"
else 
  echo -e $2 
fi

exit 0