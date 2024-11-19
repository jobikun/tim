# 创建项目目录
mkdir chat-app
cd chat-app

# 创建前端项目
vue create client
cd client
npm install element-ui socket.io-client axios
cd ..

# 创建后端项目
mkdir server
cd server
npm init -y
npm install express socket.io mongoose cors dotenv bcryptjs jsonwebtoken 