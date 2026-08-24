#!/bin/bash

set -e

SERVER="root@82.165.188.135"
SOCKET="/tmp/dnd-tool-ssh"

cleanup() {
    ssh -S "$SOCKET" -O exit "$SERVER" 2>/dev/null || true
    rm -f "$SOCKET"
}

trap cleanup EXIT

echo "==> Opening SSH connection..."
ssh -M -S "$SOCKET" -fnNT "$SERVER"

echo "==> Building Flutter web app..."
cd flutter
flutter build web --release
cd ..

echo "==> Uploading Flutter frontend..."
rsync -avz --delete \
    -e "ssh -S $SOCKET" \
    flutter/build/web/ \
    "$SERVER:/root/projects/dnd-frontend/"

echo "==> Uploading backend..."
rsync -avz --delete \
    -e "ssh -S $SOCKET" \
    backend/ \
    "$SERVER:/root/projects/dnd-backend/"

echo "==> Uploading web server..."
rsync -avz --delete \
    -e "ssh -S $SOCKET" \
    webserver/ \
    "$SERVER:/root/projects/dnd-webserver/"

echo "==> Restarting backend and web server..."
ssh -S "$SOCKET" "$SERVER" 'pm2 restart backend web-server'

echo "==> Deployment complete!"