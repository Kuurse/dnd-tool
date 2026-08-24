// Dependencies
const fs = require('fs');
const http = require('http');
const express = require('express');

const app = express();

//app.use(history());
app.use('/', express.static('/root/projects/dnd-frontend'));

// Starting both http & https servers
const httpServer = http.createServer(app);

httpServer.listen(80, () => {
	console.log('HTTP Server running on port 80');
});
