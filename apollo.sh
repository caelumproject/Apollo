#! /bin/bash

# Import configuration file
source testnet.env

# Define some pretty shell colors
RED='\033[0;31m'
GREEN='\033[0;33m'
NC='\033[0m'

# Restart the nodes.
restart() {
  stop
  wait
  start
}

# List our coinbase account. If none exists, create a new one.
list() {
  accounts=$(caelum --datadir ${DATADIR}/${NAME} account list | awk -F'[{}]' '{print $2}')
  if [ -z "$accounts" ]
  then
    caelum --datadir ${DATADIR}/${NAME} init ./config/chain/testnet/CLMP_5.json
    echo "no input" # Create account????
    read -p "Do you want to create a new coinbase account?"
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      new
    else
      echo Account creation aborted by user
      exit
    fi
  else
    echo -e Your Caelum addresses found: ${GREEN} $accounts ${NC}
    echo Primary coinbase: $accounts | awk '{print $1;}'
  fi
}

rename() {

  echo "Current masternode name: ${NAME}"
  read -p "Enter the new masternode name:"

  sudo mv ${DATADIR}/${NAME} ${DATADIR}/${REPLY}
  sudo rm -rf ${DATADIR}/${NAME}

  sed -i "/NAME/s/=.*/=${REPLY}/" testnet.env # Append coinbase

  echo "Masternode ${NAME} renamed to $REPLY"

}

import() {}

# Create a new account and ask to save it in the configuration
new() {

  caelum --datadir ${DATADIR}/${NAME} account new
  echo
  # echo Copy this address and use it as coinbase address on CaelumMaster.
  # echo Afterwards, paste it inside your configuration file at COINBASE parameter.
  # echo Paste the account password in your configuration file at COINBASE_PASSWORD parameter.
  save_config
}

# Write configuration files
save_config() {
  read -p "Do you want to save the values to the configuration file? (y/n)"
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    get_all_coinbases=$(caelum --datadir ${DATADIR}/${NAME} account list | awk -F'[{}]' '{print $2}' )
    get_coinbase=$(echo $get_all_coinbases | awk '{print $1;}')
    read -p "Save the masternode ${get_coinbase} coinbase to configuration file? (y/n)"
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      read -s -p "Coinbase unlocking password? "
      echo
      sed -i "/COINBASE/s/=.*/=${get_coinbase}/" testnet.env # Append coinbase
      echo $REPLY > .pwd # Save to .pwd file
    else
      echo Account creation aborted by user
      exit
    fi
    echo
    echo Configuration file saved!
  else
    echo Action aborted by user
    exit
  fi
}

# Stop masternodes
stop() {
  echo Stopping all caelum nodes...
  killall -HUP caelum
  echo All caelum nodes stopped.
}

# Start masternodes
start() {
  list
  echo Account $COINBASE will be used as node coinbase address.

  caelum \
    --bootnodes "enode://fea3712d633300fc5c3ee9afbebc39e22245ee70592afd84b20778eff6fe3d71351ee7bafddb7dca3535c798a8fb4dd0c912848682579530483b638521e6f311@104.248.93.200:30301,enode://2aa2134aa2a1df5b9fd23e8df5bab6b57ce59148434fb42f2dd154a3fd9de182d65963dc7faecb16c4483f18d608f3740dd3783a8e7bb61c4ade8d25ca72fbf1@104.248.93.200:30344" --syncmode "full" \
    --datadir ${DATADIR}/${NAME} --networkid 159 --port $PORT \
    --announce-txs \
    --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8545 --rpcvhosts "*" \
    --ws --wsaddr 0.0.0.0 --wsport 8546 --wsorigins "*" \
    --unlock "$COINBASE" --password ./.pwd \
    --ethstats "$NAME:caelumTestNet@104.248.93.199:3004" \
    --mine --store-reward --verbosity 3 &
  process_id=$!

  echo Caelum started with process id $process_id
  sed -i "/PID/s/=.*/=${process_id}/" testnet.env # Write process ID to config for logs
}


if [ $# -eq 0 ]
then
  echo "No arguments supplied"
fi

case "$1" in
  list ) list ;;
  new ) new ;;
  stop ) stop ;;
  start ) start ;;
  rename ) rename ;;
  nvm ) save_config ;;
esac
