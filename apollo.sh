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
    caelum --datadir ${DATADIR}/${NAME} init ./config/chain/testnet/clmp_pre_alpha.json
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

import() {
  echo "Pending integration"
}

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
  echo Stopping caelum node ${PID}
  kill -SIGINT ${PID}
  echo Caelum node ${PID} stopped.
}

force () {
  echo Stopping all caelum nodes...
  killall -HUP caelum
  echo All caelum nodes stopped.
}

log() {
  echo Showing log file. Ctrl+C to exit
  tail -f -n 2 ${DATADIR}/${NAME}log.txt
}

# Start masternodes
start() {
  list
  echo Account $COINBASE will be used as node coinbase address.

  caelum \
    --bootnodes "enode://f29dbe9e359e2241049951c05c54d4e01a1e65be262d70543f7e8004ef6d6449474880208d96e05a8c58009410ccc9dc0ceccb199523608e72a975d3c937d792@167.86.104.27:38888,enode://f29dbe9e359e2241049951c05c54d4e01a1e65be262d70543f7e8004ef6d6449474880208d96e05a8c58009410ccc9dc0ceccb199523608e72a975d3c937d792@167.86.104.128:38888" --syncmode "full" \
    --datadir ${DATADIR}/${NAME} --networkid 159 --port $PORT \
    --announce-txs \
    --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8545 --rpcvhosts "*" \
    --ws --wsaddr 0.0.0.0 --wsport 8546 --wsorigins "*" \
    --unlock "$COINBASE" --password ./.pwd \
    --ethstats "$NAME:caelumTestNet@167.86.104.182:3004" \
    --mine --store-reward --verbosity 3 >${DATADIR}/${NAME}/log.txt 2>&1 &
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
  log) log ;;
  force-close) force ;;
esac
