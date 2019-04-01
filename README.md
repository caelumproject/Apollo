# Apollo

### :rocket: Strap some rockets to go-caelum

**Installation**

`git clone https://github.com/caelumproject/Apollo && chmod -R 755 Apollo/`

If you don't have Golang and/or go-caelum installed yet, run our installation script `./install-server.sh`.

Depending on your security level in your shell, the root password can be asked during the installation script to execute `sudo` commands during installation.

**Configuration**

  - Set the folder where caelum should store the data in `DATADIR`.
  - Set your prefered public `PORT`.
  - Choose a unique `NAME` to get listed on the statistics page.

**Usage**

Run the apollo scipt by executing `./apollo.sh` along with one of the following parameters:

 - `list` Gives an overview of all accounts
 - `new` Create a new account
 - `start` Launches the masternode
 - `stop` Stops the caelum masternodes
 - `restart` Reboots the masternode

 **Hint!** You can run all these actions in one go by running `./apollo.sh start`. This executes all needed steps in a single command.

 Enter any key in your console to let the masternode run in the background.

 To know your coinbase account when setting up a masternode on https://master.testnet.caelumfoundation.com use the command `./apollo.sh list`.



 Check if you are displayed on our stats page https://stats.testnet.caelumfoundation.com/

 Send our developers a DM to receive some testnet tokens in order to activate and setup your masternode.

 Subscribe to the Telegram channel for updates/instructions as masternode owner https://t.me/joinchat/AAAAAFankV-nfwLbBRbHMw

---

**Common issues**

`permission denied` when running `.sh` files: First execute `chmod +x FILE_NAME` to grant permissions

`error: Your local changes to the following files would be overwritten by merge:` Stash the local changes made by the `chmod` action by executing `git stash` first.

**Upgrading go-caelum**

Whenever new updates are available, please run `./upgrade-caelum.sh`


