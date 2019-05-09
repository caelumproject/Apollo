# Apollo

### :rocket: Strap some rockets to go-caelum

**Installation**

Depending on your security level in your shell, the root password can be asked during the installation script to execute `sudo` commands during installation.

`git clone https://github.com/caelumproject/Apollo`

If you don't have Golang and/or go-caelum installed yet, run our installation script:
`cd Apollo`
`bash install-server.sh`.
Follow the prompts and accept/enter when asked. Once finished you might be asked to close/restart the terminal.
On a successfull install you should have `go-caelum` as a directory alongside `Apollo`.

Optional: create a directory to store the masternode/chain data:
`mkdir YOUR_DATADIR`

**Configuration**

Copy the `testnet.example.env` file by executing `cp testnet.example.env testnet.env` first.
Copy the `example.pwd` file by executing `cp example.pwd pwd`.

Edit `/Apollo/testnet.env` with the following:

  - Set the folder where caelum should store the data in `DATADIR`. If you didn't make a directory earlier, leave as is.
  - Set your prefered public `PORT`.
  - Choose a unique `NAME` to get listed on the statistics page.

**Usage**

Run the apollo scipt by executing `bash apollo.sh` along with one of the following parameters:

 - `list` Gives an overview of all accounts
 - `new` Create a new account
 - `start` Launches the masternode
 - `stop` Stops the caelum masternodes
 - `restart` Reboots the masternode
 - `rename` Rename your masternode
 - `log` Shows the daemon output. Ctrl+c to exit.

 **Hint!** You can run all these actions in one go by running `bash apollo.sh start`. This executes all needed steps in a single command.

 Enter any key in your console to let the masternode run in the background.

 To know your coinbase account when setting up a masternode on https://master.testnet.caelumfoundation.com use the command `bash apollo.sh list`.

 Check if you are displayed on our stats page https://stats.testnet.caelumfoundation.com/

 Send our developers a DM to receive some testnet tokens in order to activate and setup your masternode.

 Subscribe to the Telegram channel for updates/instructions as masternode owner https://t.me/joinchat/AAAAAFankV-nfwLbBRbHMw

---

**Setting up a masternode with no initial masternode address**

`bash apollo.sh start` for the first time or `bash apollo.sh new`

It will ask you if you want to create a new coinbase account. Accepting (`y`) will then prompt you for a password.

When asked to save the values/masternode to the configuration file say yes. (`y`)

The password will be saved in `/Apollo/.pwd` and the address will be saved in `/Apollo/testnet.env`.

Re-enter the password you created. This will then start the node and begin syncing.

**Setting up a masternode with an existing masternode address (importing)**

`caelum account import --password /path/to/Apollo/.pwd --datadir YOUR_DATADIR /path/to/PRIVATE_KEY`

`YOUR_DATADIR` will be the path specified for `DATADIR` in `/Apollo/testnet.env`.

`PRIVATE_KEY` needs to be a text file containing the address's private key. You can create a blank file with `nano` or `vi` and paste the private key, then save it. **Once the import is complete, delete this text file.**

On success, `cd Apollo` then edit `testnet.env` and make `COINBASE` = your masternode address, minus the leading `0x`. Save, then `bash apollo.sh start`.

**Connecting to our testnet with MetaMask**

You will need to go to https://master.testnet.caelumfoundation.com/

There you must click the `login`button. If you use metamask, you need to connect to a custom network first

```
RPC URL: https://rpc.testnet.caelumfoundation.com
Chain ID: 159
Symbol CLMPTESTNET
Nickname CLMP_TESTNET
```

**Run latest dev branch**

```
cd && git clone https://github.com/caelumproject/go-caelum-dev && cd go-caelum-dev && git checkout rebrand && make caelum && sudo rm  /usr/local/bin/caelum && sudo cp build/bin/caelum /usr/local/bin
```

To return to the stable version:

```
cd && cd go-caelum && git checkout master && make caelum && sudo rm  /usr/local/bin/caelum && sudo cp build/bin/caelum /usr/local/bin
```

---

**Common issues**

Note: You might need `sudo` permissions to run any commands below.

On first install: `chmod: changing permissions of FILE/DIR denied`: rerun `chmod -R 755 Apollo` with `sudo` permissions.

`permission denied` when running `.sh` files: First execute `chmod +x FILE_NAME` to grant permissions

When updating via `git pull`: `error: Your local changes to the following files would be overwritten by merge:` Stash the local changes made by the `chmod` action by executing `git stash` first.

**Upgrading go-caelum**

Whenever new updates are available, please run `bash upgrade-caelum.sh`.

**Upgrade Apollo**

`cd && rm -rf Apollo && git clone https://github.com/caelumproject/Apollo && chmod -R 755 Apollo/ && cd Apollo`

This will remove the repository and reinstall it completely.

**Known bugs**

After creating the initial account, chances are likely that your node will start without unlocking the account first. Until this is fixed, we recommend you, after first run, to stop the node and restart it. Check the logs to confirm it's running!.
