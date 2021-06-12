import consumer from "./consumer"

const MyChannel = consumer.subscriptions.create({ channel: "GeneralChatChannel" }, {
  connected() {

  },

  disconnected() {

  },

  received(data) {
    var general_chat_container = document.getElementById("chat-content");
    if (general_chat_container) {
      $("#chat-content").append(data["general_message"]);
      general_chat_container.scrollTop = general_chat_container.scrollHeight;
    }
    var chat_log = document.getElementById("chat-log");
    if (chat_log) {
      $("#chat-log").append(data["individual_message"]);
      chat_log.scrollTop = chat_log.scrollHeight;
    }
    var room_message_container = document.getElementById("messages");
    if (room_message_container) {
      $("#messages").append(data["room_message"]);
      room_message_container.scrollTop = room_message_container.scrollHeight;
      var room_chat_sidebar = document.getElementById("room-message-container");
      if(room_chat_sidebar.style.display == "none"){
        var room_chat_notice = document.getElementById("room-chat-notice");
        if(room_chat_notice){
          room_chat_notice.style.display = "inline-block";
        }
      }
    }
    var notice_content = document.getElementById("notice-message-container");
    var notice_message = document.getElementById("notice-message");
    var notice_text = `${data['send_user']}から、メッセージを受信しました。`;
    if (notice_content) {
      notice_content.style.display = "block";
      notice_message.innerHTML = notice_text;
    }
  }
});

