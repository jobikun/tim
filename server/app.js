const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "http://localhost:8080",
    methods: ["GET", "POST"]
  }
});

app.use(cors());
app.use(express.json());

// 连接MongoDB
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

// Socket.io 连接处理
io.on('connection', (socket) => {
  console.log('用户已连接');
  
  socket.on('sendMessage', (message) => {
    io.emit('message', message);
  });

  socket.on('disconnect', () => {
    console.log('用户已断开连接');
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`服务器运行在端口 ${PORT}`);
}); 