# DND Tool
## Setting up
```
cd
git clone https://github.com/Kuurse/dnd-tool.git
sudo apt install npm libcap2-bin 
sudo npm install -g pm2
cd $HOME/dnd-tool/webserver/
npm install express
sudo setcap cap_net_bind_service=+ep `readlink -f \`which node\``
cd ../backend/
npm install websocket
pm2 start $HOME/dnd-tool/backend/backend.js
pm2 start $HOME/dnd-tool/webserver/web-server.js
contab $HOME/dnd-tool/crontab
```

## Publishing updates

### Flutter front-end
```
cd ./flutter/
flutter build web --release && rsync -avz --delete build/web/ root@82.165.188.135:/root/projects/dnd-frontend/
```
Build files should be located in `./flutter/build/web/`

