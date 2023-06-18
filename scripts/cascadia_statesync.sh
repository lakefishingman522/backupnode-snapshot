#!/bin/bash

###
# https://rpc.cascadianet.net:443
# https://rpc.cascadia.forbole.com:443
# https://rpc-cascadia.ecostake.com:443
# https://cascadia-rpc.polkachu.com:443
# https://rpc-cascadia-ia.notional.ventures:443
# http://node.d3cascadia.cloud:26657
# http://cascadia.c29r3.xyz:80/rpc
###

###
# cascadia statesync cron job
# 0 5 * * 1 /bin/bash -c '/home/user/CASCCADIA_statesync.sh'
###

CASCCADIA_PATH="$HOME/.cacadiad"
SERVICE_NAME="cascadiad"

sudo systemctl stop ${SERVICE_NAME}

SNAP_RPC="https://snapshot.cascadia.foundation"
# SNAP_RPC="http://node.d3cascadia.cloud:26657"


LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
#s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ${CASCCADIA_PATH}/config/config.toml

sudo systemctl stop ${SERVICE_NAME}

cascadia tendermint unsafe-reset-all --home ${CASCCADIA_PATH} --keep-addr-book

echo Restart
sudo systemctl restart ${SERVICE_NAME}
# sudo journalctl -u ${SERVICE_NAME} -f --no-hostname | grep statesync
