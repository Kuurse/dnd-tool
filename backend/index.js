var WebSocketServer = require('websocket').server;
var http = require('http');
var server = http.createServer(
    function(request, response) {
      console.log((new Date()) + ' Received request for ' + request.url); 
      response.writeHead(200); 
      response.end();
    }
);

let initiatives = []

const port = 8080;
server.listen(
    port,
    function() { 
        console.log(new Date() + ' HTTP Server is listening on port ' + port);
    }
);

wsServer = new WebSocketServer({ 
    httpServer: server, 
    // You should not use autoAcceptConnections for production 
    // applications, as it defeats all standard cross-origin protection 
    // facilities built into the protocol and the browser. You should
    // *always* verify the connection's origin and decide whether
    // to accept it or not.
    autoAcceptConnections: false
});

function originIsAllowed(origin) {  
    // put logic here to detect whether the specified origin is allowed.  
    return true;
}

function addCharacter(response) {
    switch (response.characterType){
        case "player" :
            const index = initiatives.findIndex((i) => i.name === response.name && i.characterType === response.characterType);
            if (index !== -1) {
                initiatives[index] = response;
            } else {
                initiatives.push(response);
            }
            break;
        case "npc" :
            let count = initiatives.filter(i => i.name.includes(response.name)).length;
            if (count > 0) {
                // contains
                response.name += " " + (count+1);
                initiatives.push(response);
            } else {
                response.name += " " + 1;
                initiatives.push(response);
            }
            break;
        default:
            console.log("characterType non valide : " + response.characterType);
            break;
    }

    initiatives = initiatives.sort((a,b) => b.initiative - a.initiative);
}

function handleMessage(message) {
    const response = JSON.parse(message.utf8Data);
    switch (response.action) {
        case "add":
            addCharacter(response);
            break;
        case "delete":
            const index = initiatives.findIndex((init) => init.name === response.name);
            initiatives.splice(index, 1);
            break;
        case "deleteAll":
            initiatives = [];
            break;
        default:
            console.log("Action non valide : " + response.action);
            break;
    }
}

wsServer.on(
    'request', 
    function(request) { 
        if (!originIsAllowed(request.origin)) {
            // Make sure we only accept requests from an allowed origin
             request.reject(); 
             console.log((new Date()) + ' Connection from origin ' + request.origin + ' rejected.');
            return;
        }

        const connection = request.accept('echo-protocol', request.origin);
        connection.send(JSON.stringify(initiatives));
        console.log((new Date()) + ' Connection accepted.');
        connection.on('message', function(message) {
            console.log("Received message : \n" + JSON.stringify(JSON.parse(message.utf8Data), null, 2));
            handleMessage(message);
            wsServer.broadcast(JSON.stringify(initiatives));
        });
        connection.on(
            'close',
            function(reasonCode, description) {
                console.log((new Date()) + ' Peer ' + connection.remoteAddress + ' disconnected.');
                console.log("Current active connections : " + wsServer.connections.length);
            }
        );
    }
);

