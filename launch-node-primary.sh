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


touch .pwd
. ${1}
# export $(cat ${1} | xargs)

WORK_DIR=$PWD
cd $WORK_DIR

if [ ! -d ./${DATADIR}/${NAME}/caelum/chaindata ]
then
  wallet=$(caelum account import --password .pwd --datadir ${DATADIR}/${NAME} <(echo ${PRIVATE_KEY}) | awk -v FS="({|})" '{print $2}')
  # Init our blockchain. Pay attention to using the correct version (testnet/main)
  caelum --datadir ${DATADIR}/${NAME} init ./config/chain/testnet/CLMP_5.json
else
  wallet=$(caelum account list --datadir ${DATADIR}/${NAME} | head -n 1 | awk -v FS="({|})" '{print $2}')
fi


echo Starting the nodes for ${wallet}...

caelum \
    --bootnodes "enode://fea3712d633300fc5c3ee9afbebc39e22245ee70592afd84b20778eff6fe3d71351ee7bafddb7dca3535c798a8fb4dd0c912848682579530483b638521e6f311@104.248.93.200:30301,enode://2aa2134aa2a1df5b9fd23e8df5bab6b57ce59148434fb42f2dd154a3fd9de182d65963dc7faecb16c4483f18d608f3740dd3783a8e7bb61c4ade8d25ca72fbf1@104.248.93.200:30344" --syncmode "full" \
    --datadir ${DATADIR}/${NAME} --networkid 159 --port $PORT \
    --announce-txs \
    --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8545 --rpcvhosts "*" \
    --ws --wsaddr 0.0.0.0 --wsport 8546 --wsorigins "*" \
    --unlock "${wallet}" --password ./.pwd  --ethstats "$NAME:caelumTestNet@104.248.93.199:3004" \
    --mine --store-reward --verbosity 3 &

wait
