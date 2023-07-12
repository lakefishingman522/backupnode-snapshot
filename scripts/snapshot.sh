#!/bin/bash
CHAIN_ID="cascadia_6102-1"
SNAP_PATH="$HOME/utility/snapshots/cascadia"
LOG_PATH="$HOME/utility/snapshots/cascadia/cascadia_log.txt"
HEIGHT_PATH="$HOME/utility/snapshots/cascadia/height"

DATA_PATH="$HOME/utility/upgradetest/.cascadiad"
SERVICE_NAME="upgradetestcascadiad1.service"
RPC_ADDRESS="http://localhost:27657"


SNAP_NAME=$(echo "${CHAIN_ID}_$(date '+%Y-%m-%d').tar.lz4")
OLD_SNAP=$(ls ${SNAP_PATH} | egrep -o "${CHAIN_ID}.*tar.lz4")


now_date() {
    echo -n $(TZ=":Europe/Moscow" date '+%Y-%m-%d_%H:%M:%S')
}


log_this() {
    YEL='\033[1;33m' # yellow
    NC='\033[0m'     # No Color
    local logging="$@"
    printf "|$(now_date)| $logging\n" | tee -a ${LOG_PATH}
}

LAST_BLOCK_HEIGHT=$(curl -s ${RPC_ADDRESS}/status | jq -r .result.sync_info.latest_block_height)
log_this "LAST_BLOCK_HEIGHT ${LAST_BLOCK_HEIGHT}"

echo ${LAST_BLOCK_HEIGHT}

echo ${LAST_BLOCK_HEIGHT} > ${HEIGHT_PATH}

log_this "Stopping ${SERVICE_NAME}"
sudo systemctl stop ${SERVICE_NAME}; echo $? >> ${LOG_PATH}

log_this "Creating new snapshot"

cp ${DATA_PATH}/data/priv_validator_state.json ${DATA_PATH}/priv_validator_state.json.backup

# time tar cf ${HOME}/${SNAP_NAME} -C ${DATA_PATH} . &>>${LOG_PATH}
{ time tar cf - -C ${DATA_PATH} data | pv -s $(du -sb ${DATA_PATH}/data | awk '{print $1}') | lz4 -c -9 > ${HOME}/${SNAP_NAME}; } | pv -b

cp ${DATA_PATH}/priv_validator_state.json.backup ${DATA_PATH}/data/priv_validator_state.json

log_this "Starting ${SERVICE_NAME}"
sudo systemctl start ${SERVICE_NAME}; echo $? >> ${LOG_PATH}

log_this "Removing old snapshot(s):"
cd ${SNAP_PATH}
rm -fv ${OLD_SNAP} &>>${LOG_PATH}

log_this "Moving new snapshot to ${SNAP_PATH}"
mv ${HOME}/${CHAIN_ID}*tar.lz4 ${SNAP_PATH} &>>${LOG_PATH}


du -hs ${SNAP_PATH}/${SNAP_NAME} | tee -a ${LOG_PATH}

log_this "Done\n---------------------------\n"
