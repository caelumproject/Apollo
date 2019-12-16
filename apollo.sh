#! /bin/bash

include () {
  if [ ! -f mainnet.env ]; then
    echo "No configuration found, proceeding to setup helper..."
    cp mainnet.example.env mainnet.env
    cp example.pwd .pwd
    echo Welcome to Caelum Apollo initial configuration helper!
    read -p "Please enter the name you want to use for your node:"
    NODENAME=$REPLY
    sed -i "/NAME/s/=.*/=${NODENAME}/" mainnet.env # Append coinbase
    read -s -p "Please input a strong password to secure your account:"
    echo $REPLY > .pwd # Save to .pwd file
  fi
  echo "Configuration file found"
  source mainnet.env
}

include

initGenesis() {
  if [ ! -d ${DATADIR}/${NAME}/caelum ]; then
    echo "No genesis found, creating genesis block..."
    caelum --datadir ${DATADIR}/${NAME} init ./config/chain/mainnet/main.json
    echo
    echo "${GREEN} Caelum genesis file initialized ${NC}"
    echo
  fi
}

checkCoinbase() {
  accounts=$(caelum --datadir ${DATADIR}/${NAME} account list | awk -F'[{}]' '{print $2}')
  if [ -z "$accounts" ]
  then
    echo
    echo "No accounts found!"
    read -p "Would you like to (I)mport an existing account or (C)reate a new one (I/C)? "
    if [[ $REPLY =~ ^[Ii]$ ]]
    then
      import
    else
      createNewAccount
    fi
  else
    echo "Account $accounts has been found"
    accounts=$(caelum --datadir ${DATADIR}/${NAME} account list | awk -F'[{}]' '{print $2}')
    get_coinbase=$(echo $accounts | awk '{print $1;}')
    sed -i "/COINBASE/s/=.*/=${get_coinbase}/" mainnet.env # Append coinbase
  fi
}

import() {
  read -s -p "Enter the private key of the account you want to import:"
  if [ ${#REPLY} -lt 64 ]
  then 
    echo "Your private key seems too short. Please start again."
    exit
  else
    echo $REPLY > .tmp
    caelum --datadir ${DATADIR}/${NAME} --password .pwd account import .tmp
    rm .tmp
    echo
    echo "Private key successfully imported!"
    echo
    accounts=$(caelum --datadir ${DATADIR}/${NAME} account list | awk -F'[{}]' '{print $2}')
    get_coinbase=$(echo $accounts | awk '{print $1;}')
    sed -i "/COINBASE/s/=.*/=${get_coinbase}/" mainnet.env # Append coinbase
    echo "All accounts found in keystore: "
    echo
    echo $accounts
    echo
    echo "To remove all excess accounts, please remove them from ${DATADIR}${NAME}/keystore"
  fi
}

createNewAccount() {
  caelum --datadir ${DATADIR}/${NAME} --password .pwd account new
  echo
  get_all_coinbases=$(caelum --datadir ${DATADIR}/${NAME} account list | awk -F'[{}]' '{print $2}' )
  get_coinbase=$(echo $get_all_coinbases | awk '{print $1;}')
  echo
  echo Address created: $get_coinbase
  sed -i "/COINBASE/s/=.*/=${get_coinbase}/" mainnet.env # Append coinbase
}

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

run() {
  # Use this for now.
  get_all_coinbases=$(caelum --datadir ${DATADIR}/${NAME} account list | awk -F'[{}]' '{print $2}' )
  get_coinbase=$(echo $get_all_coinbases | awk '{print $1;}')

  caelum \
    --bootnodes "enode://507a4a44b7dd697af2c468ee031890d6b902406f19434a36d001c6f8897f90abef4f9260c575877b8cd286647352aa9da8bd3adfe16bec7c2873cfdd5a7d12ce@80.240.21.146:30303,enode://60ae508f30eebdb6ccc86ccba466cc6e044faa4a898c2428d8a55219234758791399e89cc8aaab101ddb75d2a177901c46d6ccbce3ef2fc0d696c300c6442636@80.240.21.146:30304,enode://40e07043cbdb9bae36d5392a9cd8848d518153c5d2d897e9f4e0f344aad9518adcc716edd29157ccf238d64b8d55715b829bcacc06eff816e1cff5e43bc61c52@80.240.28.135:30344,enode://b488ab8ec6cce2ddd773d2b19ec7d3652b0051d73244e05c76f87e0c87a7a7924cc834b410d8220926b7025a4811f29b58235a3130b01d3a1482e63a98cdb5a9@5.189.139.34:30346" --syncmode "full" \
    --datadir ${DATADIR}/${NAME} --networkid 159 --port $PORT \
    --announce-txs \
    --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8545 --rpcvhosts "*" \
    --ws --wsaddr 0.0.0.0 --wsport 8546 --wsorigins "*" \
    --unlock "$get_coinbase" --password ./.pwd \
    --ethstats "$NAME:CaelumMain@80.240.21.146:3004" \
    --mine --store-reward --verbosity 3 >${DATADIR}/${NAME}/log.txt 2>&1 &
  process_id=$!

  sed -i "/PID/s/=.*/=${process_id}/" mainnet.env # Write process ID to config for logs
  echo Caelum started with process id $process_id
}

update() {
  git pull
}

log() {
  echo Showing log file. Ctrl+C to exit
  tail -f -n 2 ${DATADIR}/${NAME}/log.txt
}

clean() {
  read -p "This will completely remove any existing data and accounts! Are you sure? (Y/N) "
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    force
    mkdir -p ./Archive
    find ./networks/ -name "UTC*" -exec cp {} "./Archive/" \;
    rm -rf ${DATADIR}
  else
    echo "canceled by user."
    exit
  fi
}

start() {
  sed -i "/COINBASE/s/=.*/=/" mainnet.env
  initGenesis
  checkCoinbase
  wait
  run
}


if [ $# -eq 0 ]
then
  echo "No arguments supplied"
fi


case "$1" in
  start ) start ;;
  import ) import ;;
  stop ) stop ;;
  force-close ) force ;;
  update ) update ;;
  clean ) clean ;;
  log ) log ;;
esac
