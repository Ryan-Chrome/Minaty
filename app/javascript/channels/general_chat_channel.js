import consumer from "./consumer"

$(document).on("turbolinks:load", function() {
  const MyChannel = consumer.subscriptions.create({ channel: "GeneralChatChannel" }, {
    connected() {

    },

    disconnected() {

    },

    received(data) {
      var general_chat_container = document.getElementById("chat-content");
      if(general_chat_container){
        $("#chat-content").append(data["general_message"]);
        general_chat_container.scrollTop = general_chat_container.scrollHeight;
      }
      var chat_log = document.getElementById("chat-log");
      if(chat_log) {
        $("#chat-log").append(data["individual_message"]);
        chat_log.scrollTop = chat_log.scrollHeight;
      }
      var room_message_container = document.getElementById("messages");
      if(room_message_container){
        $("#messages").append(data["room_message"]);
        room_message_container.scrollTop = room_message_container.scrollHeight;
      }
    }

  });
  
});
