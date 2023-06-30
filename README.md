## install pv
```bash
sudo apt install pv
```
## install jq

```bash
sudo apt update
sudo apt install -y jq
```
## set user can use sudo systemctl start/stop without password

```
sudo visudo

ubuntu ALL = NOPASSWD: /bin/systemctl start cascadia.service
ubuntu ALL = NOPASSWD: /bin/systemctl stop cascadia.service

```

## backup data/priv_validator_state.json
```
mv ~/.cascadiad/data/priv_validator_state.json ~/.cascadiad/priv_validator_state.json.backup
```
