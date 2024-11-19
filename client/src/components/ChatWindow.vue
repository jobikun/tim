<template>
  <div class="chat-container">
    <el-container>
      <!-- 左侧联系人列表 -->
      <el-aside width="250px">
        <div class="contact-list">
          <div class="user-info">
            <el-avatar :src="currentUser.avatar"></el-avatar>
            <span>{{ currentUser.username }}</span>
          </div>
          <el-menu>
            <el-menu-item v-for="contact in contacts" :key="contact._id" @click="selectContact(contact)">
              <el-avatar :size="40" :src="contact.avatar"></el-avatar>
              <span>{{ contact.username }}</span>
            </el-menu-item>
          </el-menu>
        </div>
      </el-aside>
      
      <!-- 右侧聊天窗口 -->
      <el-main>
        <div class="chat-window">
          <div class="chat-header">
            <span>{{ selectedContact ? selectedContact.username : '请选择联系人' }}</span>
          </div>
          <div class="message-list" ref="messageList">
            <div v-for="msg in messages" :key="msg._id" :class="['message', msg.sender === currentUser._id ? 'sent' : 'received']">
              <el-avatar :size="30" :src="msg.sender === currentUser._id ? currentUser.avatar : selectedContact.avatar"></el-avatar>
              <div class="message-content">{{ msg.content }}</div>
            </div>
          </div>
          <div class="message-input">
            <el-input
              v-model="newMessage"
              type="textarea"
              :rows="3"
              placeholder="输入消息..."
              @keyup.enter.native="sendMessage"
            ></el-input>
            <el-button type="primary" @click="sendMessage">发送</el-button>
          </div>
        </div>
      </el-main>
    </el-container>
  </div>
</template>

<script>
import io from 'socket.io-client';

export default {
  name: 'ChatWindow',
  data() {
    return {
      socket: null,
      currentUser: {},
      contacts: [],
      selectedContact: null,
      messages: [],
      newMessage: ''
    };
  },
  created() {
    this.initSocket();
    this.fetchCurrentUser();
    this.fetchContacts();
  },
  methods: {
    initSocket() {
      this.socket = io('http://113.44.92.80');
      this.socket.on('message', this.handleNewMessage);
    },
    async fetchCurrentUser() {
      // 实现获取当前用户信息的逻辑
    },
    async fetchContacts() {
      // 实现获取联系人列表的逻辑
    },
    selectContact(contact) {
      this.selectedContact = contact;
      this.fetchMessages(contact._id);
    },
    async fetchMessages(contactId) {
      // 实现获取消息历史的逻辑
    },
    sendMessage() {
      if (!this.newMessage.trim() || !this.selectedContact) return;
      
      const message = {
        sender: this.currentUser._id,
        receiver: this.selectedContact._id,
        content: this.newMessage,
        type: 'text'
      };
      
      this.socket.emit('sendMessage', message);
      this.newMessage = '';
    },
    handleNewMessage(message) {
      this.messages.push(message);
      this.$nextTick(() => {
        this.scrollToBottom();
      });
    },
    scrollToBottom() {
      const messageList = this.$refs.messageList;
      messageList.scrollTop = messageList.scrollHeight;
    }
  }
};
</script>

<style scoped>
.chat-container {
  height: 100vh;
}

.contact-list {
  height: 100%;
  border-right: 1px solid #dcdfe6;
}

.user-info {
  padding: 20px;
  border-bottom: 1px solid #dcdfe6;
}

.chat-window {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.chat-header {
  padding: 20px;
  border-bottom: 1px solid #dcdfe6;
}

.message-list {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}

.message {
  display: flex;
  margin-bottom: 20px;
}

.message.sent {
  flex-direction: row-reverse;
}

.message-content {
  max-width: 60%;
  padding: 10px;
  border-radius: 4px;
  margin: 0 10px;
}

.sent .message-content {
  background-color: #409EFF;
  color: white;
}

.received .message-content {
  background-color: #f4f4f4;
}

.message-input {
  padding: 20px;
  border-top: 1px solid #dcdfe6;
}
</style> 