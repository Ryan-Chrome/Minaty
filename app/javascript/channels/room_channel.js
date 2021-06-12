import consumer from "./consumer"

$(document).on("turbolinks:load", function(){
  var room_page = document.getElementById("meeting-room");
  if (room_page) {
    const RoomChannel = consumer.subscriptions.create({ channel: "RoomChannel", room: $("#meeting-room").data("room_id") }, {
      connected() {

      },

      disconnected() {

      },

      received(data) {
        if (data["user_list_content"]) {
          $("#room-users-list").append(data["user_list_content"]);
          var invitation_user_content = document.getElementById(`invitation-user-${data["invitation_user_list_content"]}`);
          var microphone = document.getElementById(`user-microphone-${data["invitation_user_list_content"]}`);
          microphone.onclick = (e) => {
            var user_list = e.target.parentNode;
            if (user_list) {
              var target_video = document.getElementById(`video-${user_list.id}`);
              if (target_video) {
                if (target_video.muted) {
                  target_video.muted = false;
                  e.target.style.color = "white";
                } else {
                  target_video.muted = true;
                  e.target.style.color = "red";
                }
              }
            }
          }
          if (invitation_user_content) {
            invitation_user_content.remove();
          }
        } else if (data["room_message"]) {
          $("#messages").append(data["room_message"]);
          var room_message_container = document.getElementById("messages");
          room_message_container.scrollTop = room_message_container.scrollHeight;
          var room_chat_sidebar = document.getElementById("room-message-container");
          if(room_chat_sidebar.style.display == "none"){
            var room_chat_notice = document.getElementById("room-chat-notice");
            if(room_chat_notice){
              room_chat_notice.style.display = "inline-block"
            }
          }
        }
      }
    });
  }
});
