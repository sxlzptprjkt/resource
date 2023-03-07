#
# // Copyright (C) 2022 Salman Wahib (sxlmnwb)
#

echo -e "\033[0;31m"
echo "  ██████ ▒██   ██▒ ██▓     ███▄ ▄███▓ ███▄    █  █     █░▓█████▄ ";
echo "▒██    ▒ ▒▒ █ █ ▒░▓██▒    ▓██▒▀█▀ ██▒ ██ ▀█   █ ▓█░ █ ░█▒██▒ ▄██░";
echo "░ ▓██▄   ░░  █   ░▒██░    ▓██    ▓██░▓██  ▀█ ██▒▒█░ █ ░█ ▒██░█▀  ";
echo "  ▒   ██▒ ░ █ █ ▒ ▒██░    ▒██    ▒██ ▓██▒  ▐▌██▒░█░ █ ░█ ░▓█  ▀█▓";
echo "▒██████▒▒▒██▒ ▒██▒░██████▒▒██▒   ░██▒▒██░   ▓██░░░██▒██▓ ░▒▓███▀▒";
echo "▒ ▒▓▒ ▒ ░▒▒ ░ ░▓ ░░ ▒░▓  ░░ ▒░   ░  ░░ ▒░   ▒ ▒ ░ ▓░▒ ▒  ▒░▒   ░ ";
echo "░ ░▒  ░ ░░░   ░▒ ░░ ░ ▒  ░░  ░      ░░ ░░   ░ ▒░  ▒ ░ ░   ░    ░ ";
echo "░  ░  ░   ░    ░    ░ ░   ░      ░      ░   ░ ░   ░   ░ ░        ";
echo "      ░   ░    ░      ░  ░       ░            ░     ░          ░ ";
echo "         Auto Installer ojo-devnet For OJO NETWORK v0.1.2        ";
echo -e "\e[0m"
sleep 1

# Variable
OJO_WALLET=wallet
OJO=ojod
OJO_ID=ojo-devnet
OJO_FOLDER=.ojo
OJO_VER=v0.1.2
OJO_REPO=https://github.com/ojo-network/ojo
OJO_DENOM=uojo
OJO_PORT=28


echo "export OJO_WALLET=${OJO_WALLET}" >> $HOME/.bash_profile
echo "export OJO=${OJO}" >> $HOME/.bash_profile
echo "export OJO_ID=${OJO_ID}" >> $HOME/.bash_profile
echo "export OJO_FOLDER=${OJO_FOLDER}" >> $HOME/.bash_profile
echo "export OJO_VER=${OJO_VER}" >> $HOME/.bash_profile
echo "export OJO_REPO=${OJO_REPO}" >> $HOME/.bash_profile
echo "export OJO_DENOM=${OJO_DENOM}" >> $HOME/.bash_profile
echo "export OJO_PORT=${OJO_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $OJO_NODENAME ]; then
        read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " OJO_NODENAME
        echo 'export OJO_NODENAME='$OJO_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$OJO_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$OJO_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$OJO_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

# Install GO
ver="1.19.5"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get devnet version of ojo
cd $HOME
rm -rf ojo
git clone $OJO_REPO
cd ojo
git checkout $OJO_VER
make install
sudo mv $HOME/go/bin/$OJO /usr/bin/

# Init generation
$OJO config chain-id $OJO_ID
$OJO config keyring-backend file
$OJO config node tcp://localhost:${OJO_PORT}657
$OJO init $OJO_NODENAME --chain-id $OJO_ID

# Set peers and seeds
PEERS="0ccc4bd8386fbec1421e3c19c24124eeb00b3293@peers-ojo-devnet.sxlzptprjkt.xyz:28656"
SEEDS=""
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$OJO_FOLDER/config/config.toml
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$OJO_FOLDER/config/config.toml

# Create file genesis.json
touch $HOME/$OJO_FOLDER/config/genesis.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${OJO_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${OJO_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${OJO_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${OJO_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${OJO_PORT}660\"%" $HOME/$OJO_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${OJO_PORT}317\"%; s%^address = \":8080\"%address = \":${OJO_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${OJO_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${OJO_PORT}091\"%" $HOME/$OJO_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$OJO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$OJO_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$OJO_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$OJO_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$OJO_DENOM\"/" $HOME/$OJO_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$OJO_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$OJO_FOLDER/config/app.toml

# Enable state sync
$OJO tendermint unsafe-reset-all --home $HOME/$OJO_FOLDER

SNAP_RPC="https://rpc-ojo-devnet.sxlzptprjkt.xyz:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo ""
echo -e "\e[1m\e[31m[!]\e[0m HEIGHT : \e[1m\e[31m$LATEST_HEIGHT\e[0m BLOCK : \e[1m\e[31m$BLOCK_HEIGHT\e[0m HASH : \e[1m\e[31m$TRUST_HASH\e[0m"
echo ""

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/$OJO_FOLDER/config/config.toml

# Create Service
sudo tee /etc/systemd/system/$OJO.service > /dev/null <<EOF
[Unit]
Description=$OJO
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $OJO) start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $OJO
sudo systemctl start $OJO

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $OJO -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${OJO_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
