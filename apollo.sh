#! /bin/bash

include () {
  if [ ! -f testnet.env ]; then
    echo "No configuration found, proceeding to setup helper..."
    cp testnet.example.env testnet.env
    cp example.pwd .pwd
    echo Welcome to Caelum Apollo initial configuration helper!
    read -p "Please enter the name you want to use for your node:"
    NODENAME=$REPLY
    sed -i "/NAME/s/=.*/=${NODENAME}/" testnet.env # Append coinbase
    read -s -p "Please input a strong password to secure your account:"
    echo $REPLY > .pwd # Save to .pwd file
  fi
  echo "Configuration file found"
  source testnet.env
}


include


initGenesis() {
  if [ ! -d ${DATADIR}/${NAME}/caelum ]; then
    echo "No genesis found, creating genesis block..."
    caelum --datadir ${DATADIR}/${NAME} init ./config/chain/testnet/eip918.json
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
    sed -i "/COINBASE/s/=.*/=${get_coinbase}/" testnet.env # Append coinbase
  fi
}


import() {
  read -s -p "Enter the private key of the account you want to import:"
  echo $REPLY > .tmp
  caelum --datadir ${DATADIR}/${NAME} --password .pwd account import .tmp
  rm .tmp
  echo
  echo "Private key successfully imported!"
  echo
  accounts=$(caelum --datadir ${DATADIR}/${NAME} account list | awk -F'[{}]' '{print $2}')
  get_coinbase=$(echo $accounts | awk '{print $1;}')
  sed -i "/COINBASE/s/=.*/=${get_coinbase}/" testnet.env # Append coinbase
  echo "All accounts found in keystore: "
  echo
  echo $accounts
  echo
  echo "To remove all excess accounts, please remove them from ${DATADIR}${NAME}/keystore"
}


createNewAccount() {
  caelum --datadir ${DATADIR}/${NAME} --password .pwd account new
  echo
  get_all_coinbases=$(caelum --datadir ${DATADIR}/${NAME} account list | awk -F'[{}]' '{print $2}' )
  get_coinbase=$(echo $get_all_coinbases | awk '{print $1;}')
  echo
  echo Address created: $get_coinbase
  sed -i "/COINBASE/s/=.*/=${get_coinbase}/" testnet.env # Append coinbase
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
  tail -f -n 2 ${DATADIR}/${NAME}/log.txt
}

run() {
  # Use this for now.
  get_all_coinbases=$(caelum --datadir ${DATADIR}/${NAME} account list | awk -F'[{}]' '{print $2}' )
  get_coinbase=$(echo $get_all_coinbases | awk '{print $1;}')

  caelum \
    --bootnodes "enode://39481ad787702347f828fe126c86d1008cdf3d34c7b24ca8448dedba19e5a020e5a6fbc3774ebcc77e197f10d86205216014fab7f24d9fd663adfac13010a004@80.240.28.135:30301,enode://7586cfcba7cc364476cd8eca038405db288a7ae820063f27ba9b1bd9697a579830baeed5aaa6b074f088094dca403e0ef589ffa34587635e9762ecefe7c5baed@167.86.104.182:30301" --syncmode "full" \
    --datadir ${DATADIR}/${NAME} --networkid 159 --port $PORT \
    --announce-txs \
    --rpc --rpccorsdomain "*" --rpcaddr 0.0.0.0 --rpcport 8545 --rpcvhosts "*" \
    --ws --wsaddr 0.0.0.0 --wsport 8546 --wsorigins "*" \
    --unlock "$get_coinbase" --password ./.pwd \
    --ethstats "$NAME:CaelumEIP@136.244.87.225:3004" \
    --mine --store-reward --verbosity 3 >${DATADIR}/${NAME}/log.txt 2>&1 &
  process_id=$!

  sed -i "/PID/s/=.*/=${process_id}/" testnet.env # Write process ID to config for logs
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
    rm -rf ${DATADIR}
  else
    echo "canceled by user."
    exit
  fi
}


start() {
  sed -i "/COINBASE/s/=.*/=/" testnet.env
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
