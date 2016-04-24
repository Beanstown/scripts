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
PURELAYERS=~/Android/aosp/purenexus
PURECMTE=~/Android/aosp/purenexuscmte

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
echo "${yellow}To Build All devices for Layers branch type 'layers'${reset}"
echo "${yellow}To Build All devices for CMTE branch type 'cmte'${reset}"
echo "${yellow}To Build All devices for Layers and CMTE branchs type 'both'${reset}"

function layers() {
  #Prepare
  BEGINLAYERS=$(date +%s)
  cd $PURELAYERS
  source build/envsetup.sh
  repo sync -j8
  mka clean
  #Angler
  brunch angler
  mv $PURELAYERS/out/target/product/angler/pure_nexus_angler-*.zip $OUTDIR
  mka clean
  #Bullhead
  brunch bullhead
  mv $PURELAYERS/out/target/product/bullhead/pure_nexus_bullhead-*.zip $OUTDIR
  mka clean
  #Deb
  brunch deb
  mv $PURELAYERS/out/target/product/deb/pure_nexus_deb-*.zip $OUTDIR
  mka clean
  #Flo
  brunch flo
  mv $PURELAYERS/out/target/product/flo/pure_nexus_flo-*.zip $OUTDIR
  mka clean
  #Flounder
  brunch flounder
  mv $PURELAYERS/out/target/product/flounder/pure_nexus_flounder-*.zip $OUTDIR
  mka clean
  #Hammerhead
  brunch hammerhead
  mv $PURELAYERS/out/target/product/hammerhead/pure_nexus_hammerhead-*.zip $OUTDIR
  mka clean
  #Shamu
  brunch shamu
  mv $PURELAYERS/out/target/product/shamu/pure_nexus_shamu-*.zip $OUTDIR
  mka clean
  #End
  ENDLAYERS=$(date +%s)
  cd ~/
  echo "${green}Layers Builds Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $(($ENDLAYERS-$BEGINLAYERS)) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
}

function cmte() {
  #Prepare
  BEGINCMTE=$(date +%s)
  cd $PURECMTE
  source build/envsetup.sh
  repo sync -j8
  mka clean
  #Angler
  brunch angler
  mv $PURECMTE/out/target/product/angler/pure_nexus_angler-*.zip $OUTDIR
  mka clean
  #Bullhead
  brunch bullhead
  mv $PURECMTE/out/target/product/bullhead/pure_nexus_bullhead-*.zip $OUTDIR
  mka clean
  #Deb
  brunch deb
  mv $PURECMTE/out/target/product/deb/pure_nexus_deb-*.zip $OUTDIR
  mka clean
  #Flo
  brunch flo
  mv $PURECMTE/out/target/product/flo/pure_nexus_flo-*.zip $OUTDIR
  mka clean
  #Flounder
  brunch flounder
  mv $PURECMTE/out/target/product/flounder/pure_nexus_flounder-*.zip $OUTDIR
  mka clean
  #Hammerhead
  brunch hammerhead
  mv $PURECMTE/out/target/product/hammerhead/pure_nexus_hammerhead-*.zip $OUTDIR
  mka clean
  #Shamu
  brunch shamu
  mv $PURECMTE/out/target/product/shamu/pure_nexus_shamu-*.zip $OUTDIR
  mka clean
  #End
  ENDCMTE=$(date +%s)
  cd ~/
  echo "${green}CMTE Builds Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $(($ENDCMTE-$BEGINCMTE)) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
}

function both() {
  BEGIN=$(date +%s)
  layers
  cmte
  END=$(date +%s)
  echo "${green}Layers and CMTE Builds Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
}
