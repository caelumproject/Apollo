#! /bin/bash

WORK_DIR=$(pwd)

get_last_version() {
  IFS=$'\n';
  for l in $(caelum version) ; do
     VAR1=$(echo $l | cut -d: -f1 | sed -e 's/\s*//');
     if [ $VAR1 == "Version" ]; then
        FOUND=$l;
     fi;
  done
  FINAL_VERSION=$(echo $FOUND | rev | cut -d":" -f1  | rev |  sed -e 's/^[[:space:]]*//');
  echo $FINAL_VERSION
}

CURRENT=get_last_version

echo installed version is $CURRENT
source ~/.profile

cd $HOME
cd $HOME/go-caelum && git checkout master && git pull && make all

sudo rm  /usr/local/bin/caelum
sudo rm  /usr/local/bin/bootnode
sudo rm  /usr/local/bin/puppeth

sudo cp $HOME/go-caelum/build/bin/caelum /usr/local/bin
sudo cp $HOME/go-caelum/build/bin/bootnode /usr/local/bin
sudo cp $HOME/go-caelum/build/bin/puppeth /usr/local/bin

cd $WORK_DIR

LAST=get_last_version
echo Newly installed version is $LAST
