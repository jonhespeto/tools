This script gets the ip address of the domain and adds it to the firewall, whitelisting access to hosts with dynamic ip addresses,
it also adds a task to the cron running once a minute to update the ufw rules if the ip address has changed.


## Howto start (Ubuntu):

### Download the script
```
wget https://raw.githubusercontent.com/jonhespeto/tools/main/ufwscript/ufwscript.sh
```
### Make this file executable
```
chmod +x ufwscript.sh
```
### Run the script
```
sudo bash ufwscript.sh
```
### At the first run you will need to enter the domain name
___
## You should also take care to update the ns record of your domain. 
