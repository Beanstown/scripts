#!/bin/bash
#Decompiles all apks in a folder

DIR=/home/nate/apps
for i in $(find $DIR -name "*.apk"); do
FILE="$i"
echo "Found $i, decompiling..."
    java -jar /usr/local/bin/apktool.jar d -f $FILE -o "${i%*.*}" 
done
