#!/bin/bash
#
# Copyright (C) 2016 BeansTown106 for PureNexusProject
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
OUTDIR=~/Android/Completed
PURE=~/Android/aosp/PureNexusMM2
FTPSERVER=uploads.androidfilehost.com
LOGIN=BeansTown106
PASSWORD=password

# Colors
green=`tput setaf 2`
red=`tput setaf 1`
yellow=`tput setaf 3`
reset=`tput sgr0`


#functions
purenexus() {
  # Prepare build environment, sync the repo, and clean the out directory
  cd ${PURE}
  source build/envsetup.sh
  repo sync -j8
  mka clean
  
  # Build the below devices 
  DEVICES="angler bullhead deb flo flounder hammerhead shamu"
  for DEVICE in ${DEVICES}
  do
    brunch ${DEVICE}
    mv ${SOURCE}/out/target/product/${DEVICE}/pure_nexus_${DEVICE}-*.zip ${OUTDIR}
    mka clean
  done
}

upload() {
  cd ${OUTDIR}
  lftp <<INPUT_END
  open sftp://${FTPSERVER}
  user ${LOGIN} ${PASSWORD}
  mput *.*
  exit
INPUT_END
}

testbuilds() {
  # Prepare build environment, sync the repo, and clean the out directory
  cd ${PURE}
  source build/envsetup.sh
  repo sync -j8
  mka clean
  
  # Build the below devices 
  DEVICES="angler shamu"
  for DEVICE in ${DEVICES}
  do
    brunch ${DEVICE}
    mv ${SOURCE}/out/target/product/${DEVICE}/pure_nexus_${DEVICE}-*.zip ${OUTDIR}
    mka clean
  done
}

# ----------------------------------------------------------
menu=
until [ "$menu" = "0" ]; do
echo ""
echo "${red}=========================================================${reset}"
echo "${red}==${reset}${green}               PureNexus Release Script              ${reset}${red}==${reset}"
echo "${red}==${reset}${green}       Lets get Ready To Build For The Masses!       ${reset}${red}==${reset}"
echo "${red}=========================================================${reset}"
echo "${red}==${reset}${yellow}   1 - Full Release and Upload                       ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   2 - Full Release without Upload                   ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   3 - Build Shamu/Angler Test Builds                ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   4 - Upload all files in Out Directory             ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   5 - Delete all files in Out Directory             ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   0 - Exit                                          ${reset}${red}==${reset}"
echo "${red}=========================================================${reset}"
echo ""
echo -n "Enter selection: "
read menu
echo ""
case ${menu} in
1 )
  # Full release and upload
  BEGIN=$(date +%s)
  purenexus
  upload
  END=$(date +%s)
  echo "${green}Full Release and Upload Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $((${END}-${BEGIN})) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
;;
#############################################################

2 )
  # Full release local
  BEGIN=$(date +%s)
  purenexus
  END=$(date +%s)
  echo "${green}Full Release Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $((${END}-${BEGIN})) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
;;
#############################################################

3 )
  # Build Angler/Shamu Test Builds
  BEGIN=$(date +%s)
  testbuilds
  END=$(date +%s)
  echo "${green}Test Builds Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $((${END}-${BEGIN})) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
;;
#############################################################

4 )
  # Upload OUTDIR
  BEGIN=$(date +%s)
  upload
  END=$(date +%s)
  echo "${green}OUTDIR Upload Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $((${END}-${BEGIN})) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
;;
#############################################################

5 )
  # Wipe contents of OUTDIR
  rm -rf ${OUTDIR}/*
  echo "${green}Wiped OUTDIR!!${reset}"
;;
#############################################################

0 ) exit ;;
* ) echo "Wrong Choice Asshole, 1-7 or 0 to exit"
    esac
done
;;
#############################################################
