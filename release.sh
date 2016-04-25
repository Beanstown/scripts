#!/bin/bash

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

#Variables
OUTDIR=~/Android/Completed
SOURCE=~/Android/aosp/purenexus

#Colors
green=`tput setaf 2`
red=`tput setaf 1`
yellow=`tput setaf 3`
reset=`tput sgr0`

echo "${red}***********************************************${reset}"
echo "${red}*${reset}${green}          PureNexus Release Script!          ${reset}${red}*${reset}"
echo "${red}*${reset}${green}   Lets get Ready To Build For The Masses!   ${reset}${red}*${reset}"
echo "${red}***********************************************${reset}"
echo " "
echo "${yellow}Choose your Release Option..${reset}"
echo "${yellow}To Build All devices for Release type 'release'${reset}"

function release() {
  #Prepare
  BEGIN=$(date +%s)
  cd $SOURCE
  source build/envsetup.sh
  repo sync -j8
  mka clean
  #Angler
  brunch angler
  mv $SOURCE/out/target/product/angler/pure_nexus_angler-*.zip $OUTDIR
  mka clean
  #Bullhead
  brunch bullhead
  mv $SOURCE/out/target/product/bullhead/pure_nexus_bullhead-*.zip $OUTDIR
  mka clean
  #Deb
  brunch deb
  mv $SOURCE/out/target/product/deb/pure_nexus_deb-*.zip $OUTDIR
  mka clean
  #Flo
  brunch flo
  mv $SOURCE/out/target/product/flo/pure_nexus_flo-*.zip $OUTDIR
  mka clean
  #Flounder
  brunch flounder
  mv $SOURCE/out/target/product/flounder/pure_nexus_flounder-*.zip $OUTDIR
  mka clean
  #Hammerhead
  brunch hammerhead
  mv $SOURCE/out/target/product/hammerhead/pure_nexus_hammerhead-*.zip $OUTDIR
  mka clean
  #Shamu
  brunch shamu
  mv $SOURCE/out/target/product/shamu/pure_nexus_shamu-*.zip $OUTDIR
  mka clean
  #End
  END=$(date +%s)
  cd ~/
  echo "${green}All Builds Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
}
