## Download latest snapshot (using the example of Cascadia)  
Stop Cascadia service  
`sudo systemctl stop cascadia.service`  

Remove old data in directory `~/.cascadia/data`  
```
cascadiad tendermint unsafe-reset-all --home $HOME/.cascadiad --keep-addr-book
```

Download snapshot  
```bash
curl -o - -L https://snapshot.cascadia.foundation/snapshots/$(curl -s https://snapshot.cascadia.foundation/snapshots/cascadia/info | jq -r .filename) | lz4 -c -d - | tar -x -C $HOME/.cascadiad data
```
![alt text](https://github.com/c29r3/cosmos-snapshots/blob/main/2021-01-20_14-19.png?raw=true)

Start service and check logs  
```
sudo systemctl start cascadia.service; \
sudo journalctl -u cascadia.service -fn 100 -o cat
```
