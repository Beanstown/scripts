#!/bin/bash

# Copyright (C) 2016 BeansTown106 for PureNexus Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Variables
OUTDIR=~/android/Completed
SOURCE=~/android/aosp/pure

# Colors
green=`tput setaf 2`
red=`tput setaf 1`
yellow=`tput setaf 3`
reset=`tput sgr0`

echo "${red}***********************************************${reset}"
echo "${red}*${reset}${green}             Pure Release Script!            ${reset}${red}*${reset}"
echo "${red}*${reset}${green}   Lets get Ready To Build For The Masses!   ${reset}${red}*${reset}"
echo "${red}***********************************************${reset}"
echo " "
echo "${yellow}Choose your Release Option..${reset}"
echo "${yellow}To Build All devices for Release type 'release'${reset}"

function release() {
  # Prepare build environment, sync repo, and clean out directory
  BEGIN=$(date +%s)
  cd ${SOURCE}
  source build/envsetup.sh
  repo sync -j8
  mka clean
  
  # Build the below devices 
  DEVICES="angler bullhead shamu"
  for DEVICE in ${DEVICES}
  do
    brunch ${DEVICE}
    mv ${SOURCE}/out/target/product/${DEVICE}/purenexus_${DEVICE}-*.zip ${OUTDIR}
    mka clean
  done
  
  # End
  END=$(date +%s)
  cd ~/
  echo "${green}All Builds Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
}
