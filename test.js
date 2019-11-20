const WebSocket = require('ws');

function heartbeat(e) {
  console.log(e && e.data, "heartbeat");
}

const client = new WebSocket('ws://127.0.0.1:9292/stream');

client.on('open', heartbeat);
client.on('ping', heartbeat);
client.on('close', heartbeat);