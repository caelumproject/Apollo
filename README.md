# Apollo

### :rocket: Strap some rockets to go-caelum

**Installation**

`git clone https://github.com/caelumproject/Apollo && chmod -R 755 Apollo/``

If you don't have Golang and/or go-caelum installed yet, run our installation script `./install-server.sh`.

Depending on your security level in your shell, the root password can be asked during the installation script to execute `sudo` commands during installation.

**Configuration**

  - run `cp example.config node.config`
  - Fill in your `PRIVATE_KEY`. Don't append the `0x`.
  - Set a strong password in file `.pwd` to unlock your account.
  - Set the folder where caelum should store the data in `DATADIR`.
  - Set your prefered public `PORT`.
  - Choose a unique `NAME` to get listed on the statistics page.

**Usage**

Run the caelum node with command `./launch-node.sh <CONFIG_FILE_PATH_AND_NAME>`.
In the example above, the full command would be `./launch-node.sh node.config`.

To run a full masternode, use the command `./launch-node-primary.sh <CONFIG_FILE_PATH_AND_NAME>`

 :warning: **Testnet notice:** Testnet users should only run the `./launch-node-primary.sh` command.

 Check if you are displayed on our stats page https://stats.testnet.caelumfoundation.com/

 Send our developers a DM to receive some testnet tokens in order to activate and setup your masternode.
 
 Subscribe to the Telegram channel for updates/instructions as masternode owner https://t.me/joinchat/AAAAAFankV-nfwLbBRbHMw

---

**Common issues**

`permission denied` when running `.sh` files: First execute `chmod +x FILE_NAME` to grant permissions

**Upgrading go-caelum**

Whenever new updates are available, please run `./upgrade-caelum.sh`
