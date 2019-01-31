# Apollo

### :rocket: Strap some rockets to go-caelum

**Installation**

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

---

**Common issues**

`permission denied` when running `.sh` files: First execute `chmod +x FILE_NAME` to grant permissions

**Upgrading go-caelum**

Whenever new updates are available, please run `./upgrade-caelum.sh`
