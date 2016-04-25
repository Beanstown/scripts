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

#Variables
OUTDIR=~/Android/Completed
PURELAYERS=~/Android/aosp/purenexus
PURECMTE=~/Android/aosp/purenexuscmte
FTPSERVER=uploads.androidfilehost.com
REMOTEPATH=/
LOGIN=BeansTown106
PASSWORD=password

#Colors
green=`tput setaf 2`
red=`tput setaf 1`
yellow=`tput setaf 3`
reset=`tput sgr0`


#functions
layers() {
  #Prepare
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
}

cmte() {
  #Prepare
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
}

upload() {
  cd $OUTDIR
  ftp -n $FTPSERVER <<INPUT_END
  quote user $LOGIN
  quote pass $PASSWORD
  cd $REMOTEPATH
  prompt off
  mput *.*
  exit
INPUT_END
}

testbuilds() {
  #Prep Layers
  cd $PURELAYERS
  source build/envsetup.sh
  repo sync -j8
  mka clean
  #Angler
  brunch angler
  mv $PURELAYERS/out/target/product/angler/pure_nexus_angler-*.zip $OUTDIR
  mka clean
  #Shamu
  brunch shamu
  mv $PURELAYERS/out/target/product/shamu/pure_nexus_shamu-*.zip $OUTDIR
  mka clean
  #Prep Cmte
  cd $PURECMTE
  source build/envsetup.sh
  repo sync -j8
  mka clean
  #Angler
  brunch angler
  mv $PURECMTE/out/target/product/angler/pure_nexus_angler-*.zip $OUTDIR
  mka clean
  #Shamu
  brunch shamu
  mv $PURECMTE/out/target/product/shamu/pure_nexus_shamu-*.zip $OUTDIR
  mka clean
}

# ----------------------------------------------------------
menu=
until [ "$menu" = "0" ]; do
echo ""
echo "${red}=========================================================${reset}"
echo "${red}==${reset}${green}               PureNexus Release Script              ${reset}${red}==${reset}"
echo "${red}==${reset}${green}       Lets get Ready To Build For The Masses!       ${reset}${red}==${reset}"
echo "${red}=========================================================${reset}"
echo "${red}==${reset}${yellow}   1 - Full Release and Upload (Layers & CMTE)       ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   2 - Full Release without Upload                   ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   3 - Build All devices for CMTE branch             ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   4 - Build All devices for Layers branch           ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   5 - Build Shamu/Angler Test Builds                ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   6 - Upload all files in Out Directory             ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   7 - Delete all files in Out Directory             ${reset}${red}==${reset}"
echo "${red}==${reset}${yellow}   0 - Exit                                          ${reset}${red}==${reset}"
echo "${red}=========================================================${reset}"
echo ""
echo -n "Enter selection: "
read menu
echo ""
case $menu in
1 )
  #Full release and upload
  BEGIN=$(date +%s)
  layers
  cmte
  upload
  END=$(date +%s)
  echo "${green}Full Release and Upload Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
;;
#############################################################

2 )
  #Full release local
  BEGIN=$(date +%s)
  layers
  cmte
  END=$(date +%s)
  echo "${green}Full Release Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
;;
#############################################################

3 )
  #Build CMTE locally
  BEGIN=$(date +%s)
  cmte
  END=$(date +%s)
  echo "${green}CMTE Builds Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
;;
#############################################################

4 )
  #Build Layers locally
  BEGIN=$(date +%s)
  layers
  END=$(date +%s)
  echo "${green}Layers Builds Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
;;
#############################################################

5 )
  #Build Angler/Shamu Test Builds
  BEGIN=$(date +%s)
  testbuilds
  END=$(date +%s)
  echo "${green}Test Builds Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
;;
#############################################################

6 )
  #Upload OUTDIR
  BEGIN=$(date +%s)
  upload
  END=$(date +%s)
  echo "${green}OUTDIR Upload Complete!!${reset}"
  echo "${green}Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}')${reset}"
;;
#############################################################

7 )
  #Wipe contents of OUTDIR
  rm -rf $OUTDIR/*
  echo "${green}Wiped OUTDIR!!${reset}"
;;
#############################################################

0 ) exit ;;
* ) echo "Wrong Choice Asshole, 1-7 or 0 to exit"
    esac
done
;;
#############################################################
