#!/bin/bash

intexit() {
    kill -HUP -$$
}

hupexit() {
    echo
    echo "Interrupted, killing daemon"
    exit
}

trap hupexit HUP
trap intexit INT

### USAGE:
# ./add-single-node.sh CONFIG_FILE

# Read our config file from command line
. ${1}

touch .pwd

WORK_DIR=$PWD
cd $WORK_DIR

if [ ! -d ./networks/testnet/nodes/1/caelum/chaindata ]
then
  wallet=$(caelum account import --password .pwd --datadir ${DATADIR}/${NAME} <(echo ${PRIVATE_KEY}) | awk -v FS="({|})" '{print $2}')
  # Init our blockchain. Pay attention to using the correct version (testnet/main)
  caelum --datadir ${DATADIR}/${NAME} init ./config/chain/testnet/genesis.json
else
  wallet=$(caelum account list --datadir ${DATADIR}/${NAME} | head -n 1 | awk -v FS="({|})" '{print $2}')
fi


echo Starting the nodes ...

caelum \
    --bootnodes "enode://f29dbe9e359e2241049951c05c54d4e01a1e65be262d70543f7e8004ef6d6449474880208d96e05a8c58009410ccc9dc0ceccb199523608e72a975d3c937d792@159.65.89.43:30301" --syncmode "full" \
    --datadir ${DATADIR}/${NAME} --networkid 159 --port $PORT \
    --unlock "${wallet}" --ethstats "$NAME:caelumTestNet@159.65.89.43:3004" \
    --password .pwd --mine &

wait
