$(document).on('turbolinks:load', () => {

    var home_index = document.getElementsByClassName("home-index-page");
    var meeting_lobby = document.getElementById("meeting-top");
    var meeting_room = document.getElementById("meeting-room");
    var meeting_new_form = document.getElementById("meeting-new-form");
    var management_user_page = document.getElementById("user-details");

    // サイドメニュー
    var sidebar_btn = document.getElementById("sidebar-btn-trigger");
    if(sidebar_btn){
        var sidebar = document.getElementById("side-menu");
        sidebar_btn.onclick = (e) => {
            if(sidebar.className == "active"){
                sidebar.classList.remove("active");
            } else {
                sidebar.classList.add("active");
            }
        }
    }
    
    if(home_index.length){
        console.log("home");
     //==============================================================|
        //ホームクロック関連
        const deg = 6;
        const hr = document.querySelector("#hr");
        const mn = document.querySelector("#mn");
        const sc = document.querySelector("#sc");
        setInterval(() => {
            let day = new Date();
            let hh = day.getHours() * 30;
            let mm = day.getMinutes() * deg;
            let ss = day.getSeconds() * deg;

            hr.style.transform = `rotateZ(${hh+(mm/12)}deg)`;
            mn.style.transform = `rotateZ(${(mm)}deg)`;
            sc.style.transform = `rotateZ(${(ss)}deg)`;
        });

        //ホームクロックによるユーザーコンテンツ高さ調整
        var clock_container = document.getElementsByClassName("clock-container")[0];
        var clock_height = clock_container.clientHeight;
        var group_list_height = document.getElementById("group-search-list");
        group_list_height.style.height =  `calc(100% - ${clock_height}px)`; 
    
     //==============================================================|
        // タイマー関連
        // タイマー表示切替
        var timer_btn = document.getElementById("header-time-btn");
        var timer_container = document.getElementById("timer-container");
        var btn_time = document.getElementById("btn-time");

        timer_btn.onclick = () => {
            if(timer_btn.classList.contains("active")){
                timer_btn.style.background = "black";
                timer_btn.style.color = "white";
                timer_btn.classList.remove("active");
                timer_container.style.display = "none";
            } else {
                timer_btn.style.background = "white";
                timer_btn.style.color = "black";
                timer_btn.classList.add("active");
                timer_container.style.display = "inline-block";
                btn_time.textContent = "Timer";
            }
        }

        var timer = document.getElementById("timer");
        var timer_start = document.getElementById("timer-start");
        var timer_stop = document.getElementById("timer-stop");
        var timer_reset = document.getElementById("timer-reset");
        var timer_start_time = document.getElementById("timer-start-time");
        var timer_schedule_link = document.getElementById("timer-schedule-link");

        // タイマー桁合わせ
        function time_digit(time){
            var num = String(time);
            if(num.length === 1){
                num = "0" + num;
            }
            return num;
        }

        // タイマー変数
        var stock_start_time;
        var stock_end_time;
        var timer_n = 0;
        var timer_s = 0;
        var timer_s_ex = 0;
        var timer_m = 0;
        var timer_m_ex = 0;
        var timer_h = 0;
        var timer_interval;

        // タイマースタート時
        timer_start.onclick = () => {
            timer_start.style.display = "none";
            timer_stop.style.display = "block";
            var now = new Date();
            var hours = time_digit(now.getHours());
            var minutes = time_digit(now.getMinutes());
            if (timer_start_time.textContent === "TIME"){
                stock_start_time = `${hours}：${minutes}`;
                timer_start_time.textContent = `${hours}：${minutes} ~ 測定中`;
            }
            timer_interval = setInterval(() => {
                timer_n = timer_n + 1;
                if(Number.isInteger(timer_n / 60)){
                    timer_s = "00"; // 8進数によるコンパイルエラー対策のためString型
                    timer_m = (timer_n / 60) - timer_m_ex;
                    timer_s_ex = timer_s_ex + 60;
                } else {
                    timer_s = timer_n - timer_s_ex;
                }
                if(Number.isInteger(timer_n / 3600)){
                    timer_m = "00";　// 8進数によるコンパイルエラー対策のためString型
                    timer_h = timer_n / 3600;
                    timer_m_ex = timer_m_ex + 60;
                }
                timer.textContent = `${time_digit(timer_h)}：${time_digit(timer_m)}：${time_digit(timer_s)}`;
                if(timer_container.style.display == "none"){
                    btn_time.textContent = `${time_digit(timer_h)}：${time_digit(timer_m)}：${time_digit(timer_s)}`;
                }
            }, 1000);
        }

        // タイマーストップ時
        timer_stop.onclick = () => {
            timer_stop.style.display = "none";
            timer_start.style.display = "block";
            clearInterval(timer_interval);
            var now = new Date();
            var hours = time_digit(now.getHours());
            var minutes = time_digit(now.getMinutes());
            stock_end_time = `${hours}：${minutes}`;
            timer_start_time.textContent = `${stock_start_time} ~ ${hours}：${minutes}`;
            timer_schedule_link.href = `/schedules/add_timer?end_time=${stock_end_time}&start_time=${stock_start_time}`;
        }

        // タイマーリセット時
        timer_reset.onclick = () => {
            timer_n = 0;
            timer_s = 0;
            timer_s_ex = 0;
            timer_m = 0;
            timer_m_ex = 0;
            timer_h = 0;
            timer_start_time.textContent = "TIME";
            timer.textContent = "00：00：00";
            clearInterval(timer_interval);
            timer_stop.style.display = "none";
            timer_start.style.display = "block";
            timer_schedule_link.href = `/schedules/add_timer?end_time=&start_time=`;
        }

     //==============================================================|
        //チャットフォーム関連
        var form_move_btn = document.getElementById("form-move");

        //マウスドラッグ処理
        form_move_btn.onmousedown = (event) => {
            document.body.style.userSelect = "none";
            document.addEventListener("mousemove", onMouseMove);
        }

        //　マウスドラッグ付与イベント
        const onMouseMove = (event) => {
            var x = event.clientX;
            var y = event.clientY;
            var body_width = document.body.clientWidth;
            var body_height = document.body.clientHeight;
            var form_container = document.getElementById("chat-form");
            var chat_area = document.getElementById("chat-text-area");
            var rect = chat_area.getBoundingClientRect();

            // X軸フォーム移動
            if(x-15.42 <= 0) {
                form_container.style.left = "0px";
            } else if(x-15.42 >= body_width-form_container.clientWidth-80){
                form_container.style.left = body_width-form_container.clientWidth-80 + "px";
            } else {
                form_container.style.left = x - 15.42 + "px";
            }

            // Y軸フォーム移動
            if(y <= 50) {
                form_container.style.top = "0px";
            } else if(y >= body_height-form_container.clientHeight+13) {
                form_container.style.top = body_height-50-form_container.clientHeight+10 + "px";
            } else {
                form_container.style.top = y - 51 + "px";
            }

            // フォーム横リサイズ制限
            chat_area.style.maxWidth = body_width-rect.left-80 + "px";
            if(parseInt(chat_area.style.width) >= parseInt(chat_area.style.maxWidth)){
                chat_area.style.width = chat_area.style.maxWidth;
            }
            
            // フォーム縦リサイズ制限
            chat_area.style.maxHeight = body_height-rect.top- 30 + "px";
            if(parseInt(chat_area.style.height) >= parseInt(chat_area.style.maxHeight)){
                chat_area.style.height = chat_area.style.maxHeight;
            }
        }

        // フォーム移動時カーソルが外れた場合の処理
        document.body.onclick = () => {
            document.body.style.userSelect = "";
            document.removeEventListener("mousemove",onMouseMove);
        }

        // フォームドロップ時アクション
        form_move_btn.onmouseup = () => {
            document.body.style.userSelect = "";
            document.removeEventListener("mousemove",onMouseMove);
        }

     //==============================================================|

        //モーダル取得
        var modal = document.getElementById("Modal");

        // チャット宛先設定モーダル関連
        var send_user_container = document.getElementById("send-user-container");
        var add_send_user_btn = document.getElementById("add-send-user");
        var send_user_close_btn = document.getElementById("send-user-close");
        var done_send_user_btn = document.getElementById("done-chat-send-user");
        add_send_user_btn.onclick = () => {
            modal.style.display = "block";
            send_user_container.style.display = "block";
        }
        send_user_close_btn.onclick = () => {
            modal.style.display = "none";
            send_user_container.style.display = "none";
        }
        done_send_user_btn.onclick = () => {
            modal.style.display = "none";
            send_user_container.style.display = "none";
        }

        // ユーザー検索モーダル関連
        var user_search_box = document.getElementById("user-search-box");
        var user_search_modal_btn = document.getElementById("user-search-btn");
        var user_search_close_btn = document.getElementById("user-search-box-close");
        user_search_modal_btn.onclick = () => {
            modal.style.display = "block";
            user_search_box.style.display = "block";
        }
        user_search_close_btn.onclick = () => {
            modal.style.display = "none";
            user_search_box.style.display = "none";
        }

        // グループ新規作成モーダル関連
        var new_group_container = document.getElementById("new-group");
        var new_group_btn = document.getElementById("new-group-btn");
        var new_group_close_btn = document.getElementById("new-group-close");
        new_group_btn.onclick = () => {
            modal.style.display = "block";
            new_group_container.style.display = "block";
        }
        new_group_close_btn.onclick = () => {
            modal.style.display = "none";
            new_group_container.style.display = "none";
        }

        //スケジュール追加モーダル関連
        var add_schedule_data_content = document.getElementById("add-schedule-data");
        var add_schedule_modal_btn = document.getElementById("add-schedule-btn");
        var add_schedule_data_close = document.getElementById("add-schedule-data-close");
        add_schedule_modal_btn.onclick = () => {
            modal.style.display = "block";
            add_schedule_data_content.style.display = "block";
        }
        add_schedule_data_close.onclick = () => {
            modal.style.display = "none";
            add_schedule_data_content.style.display = "none";
        }

        //スケジュール編集モーダル関連
        var edit_schedule_content = document.getElementById("edit-schedule");
        var edit_schedule_modal_btn = document.getElementById("edit-schedule-btn");
        var edit_schedule_close = document.getElementById("edit-schedule-close");
        edit_schedule_modal_btn.onclick = () => {
            modal.style.display = "block";
            edit_schedule_content.style.display = "block";
            if(!edit_schedule_modal_btn.classList.contains("done")){
                edit_schedule_modal_btn.classList.add("done");
                for(var i=0; i < number; i++){
                    var schedule = document.getElementsByClassName(`edit-schedule-${i}`);
                    var schedule_height = 0;
                    for(var s=0; s < schedule.length; s++){
                        schedule_height += schedule[s].offsetHeight;
                    }
                    if(schedule_height < 40){
                        var schedule_time = document.getElementById(`edit-time-${i}`);
                        var schedule_name = document.getElementById(`edit-schedule-name-${i}`);
                        schedule_time.style.display = "none";
                        schedule_name.style.display = "none";
                        for(var s=0; s < schedule.length; s++){
                            schedule[s].classList.add("edit-need-details");
                            if(s === 0){
                                var schedule_details_element = document.createElement("p");
                                schedule_details_element.setAttribute("id", `edit-schedule-details-${i}`);
                                schedule_details_element.setAttribute("class", `edit-schedule-details`);
                                var schedule_details_text_1 = document.createTextNode(`${schedule_name.textContent}`);
                                var schedule_details_text_2 = document.createElement("br");
                                var schedule_details_text_3 = document.createTextNode(`${schedule_time.textContent}`);
                                schedule_details_element.appendChild(schedule_details_text_1);
                                schedule_details_element.appendChild(schedule_details_text_2);
                                schedule_details_element.appendChild(schedule_details_text_3);
                                schedule[0].appendChild(schedule_details_element);
                            }
                            schedule[s].addEventListener("mouseover", (event) => {
                                var schedule_number = (event.target.classList[0].replace(/[^0-9]/g, ''));
                                var schedule_details = document.getElementById(`edit-schedule-details-${schedule_number}`);
                                schedule_details.style.display = "block";
                            }, false);
                            schedule[s].addEventListener("mouseleave", (event) => {
                                var schedule_number = (event.target.classList[0].replace(/[^0-9]/g, ''));
                                var schedule_details = document.getElementById(`edit-schedule-details-${schedule_number}`);
                                schedule_details.style.display = "none";
                            }, false);
                        }
                    }
                }
            }
        }
        edit_schedule_close.onclick = () => {
            modal.style.display = "none";
            edit_schedule_content.style.display = "none";
        }

     //==============================================================|

        //ホームチャット関連
        var general_chat_container = document.getElementById("chat-content");
        general_chat_container.scrollTo(0, general_chat_container.scrollHeight);
        var page_number = 2;
        var total_page = $("#chat-content").data("page_count");
        var scroll_height = general_chat_container.scrollHeight;
        var offset_height = general_chat_container.offsetHeight;
        if(offset_height == scroll_height && total_page > 1){
            var message_content_scroll = general_chat_container.scrollHeight;
            $.ajax({
                url: `/general_messages/home_chat_ajax?page=${page_number}`,
            }).done(function(data) {
                $("#chat-content").prepend($(data).find("#chat-content").html());
                $("#chat-content").scrollTop(general_chat_container.scrollHeight - message_content_scroll);
                page_number++;
            });
        }
        $("#chat-content").scroll(function(){
            if(($("#chat-content").scrollTop() == 0) && (page_number <= Number(total_page))){
                var message_content_scroll = general_chat_container.scrollHeight;
                $.ajax({
                    url: `/general_messages/home_chat_ajax?page=${page_number}`,
                }).done(function(data) {
                    $("#chat-content").prepend($(data).find("#chat-content").html());
                    $("#chat-content").scrollTop(general_chat_container.scrollHeight - message_content_scroll);
                    page_number++;
                });
            }
        });

        //返信ボタン
        var message_return_btn = document.getElementsByClassName("return-message-btn");
        var setReturnMessage = (e) => {
            var user_name = e.target.nextElementSibling.textContent;
            var user_id = e.target.dataset.message_user;
            var chat_send_list_container = document.getElementById("send-list");
            var chat_send_user_list = document.getElementById("chat-send-user-list");
            var chat_send_form_list = document.getElementById("chat-send-users-form-list");
            var chat_send_form_input = chat_send_form_list.children;
            var check_selectors = chat_send_list_container.getElementsByClassName(`user-selector-${user_id}`);
            for(i=0; i < check_selectors.length;i++){
                var check_box = check_selectors[i].getElementsByTagName("input")[0];
                var user_list = check_selectors[i].parentNode;
                var user_list_selectors = user_list.children;
                var group_div = user_list.previousElementSibling;
                var group_div_checkbox = group_div.getElementsByTagName("input")[0];
                var selector_count = 0;
                check_box.checked = true;
                check_selectors[i].style.color = "black";
                check_selectors[i].style.backgroundColor = "white";
                check_selectors[i].style.fontWeight = "bold";
                for(var list_number=0; list_number < user_list_selectors.length;list_number++){
                    if(user_list_selectors[list_number].getElementsByTagName("input")[0].checked){
                        selector_count = selector_count +1;
                    } 
                    if(selector_count >= user_list_selectors.length){
                        group_div_checkbox.checked = true;
                    }
                }
            }

            for(i=0; i < chat_send_form_input.length;i++){
                var remove_user_id = chat_send_form_input[i].value;
                if(remove_user_id != user_id) {
                    var remove_send_selector = chat_send_list_container.getElementsByClassName(`user-selector-${remove_user_id}`);
                    for(s=0; s < remove_send_selector.length;s++){
                        var remove_checkbox = remove_send_selector[s].getElementsByTagName("input")[0];
                        remove_checkbox.checked = false;
                        remove_send_selector[s].style.color = "white";
                        remove_send_selector[s].style.backgroundColor = "";
                        remove_send_selector[s].style.fontWeight = "";
                        var user_list = remove_send_selector[s].parentNode;
                        var user_list_selectors = user_list.children;
                        var group_div = user_list.previousElementSibling;
                        var group_div_checkbox = group_div.getElementsByTagName("input")[0];
                        var selector_count = 0;
                        for(var list_number=0; list_number < user_list_selectors.length;list_number++){
                            if(user_list_selectors[list_number].getElementsByTagName("input")[0].checked){
                                selector_count = selector_count -1;
                            }
                            if(selector_count <= 0){
                                group_div_checkbox.checked = false;
                            }
                        }
                    }
                } 
            }

            var send_user_element = document.createElement("li");
            var send_user_element_text = document.createTextNode(`${user_name}`);
            send_user_element.setAttribute("id", `send-selected-user-${user_id}`);
            send_user_element.setAttribute("class", "send-selected-users");
            send_user_element.appendChild(send_user_element_text);
            chat_send_user_list.innerHTML = "";
            chat_send_user_list.appendChild(send_user_element);
            var chat_send_form_element = document.createElement("input");
            chat_send_form_element.setAttribute("type", "hidden");
            chat_send_form_element.setAttribute("name", "general_message_send_users[]");
            chat_send_form_element.setAttribute("id", `chat-send-users-form-${user_id}`);
            chat_send_form_element.value = user_id;
            chat_send_form_list.innerHTML = "";
            chat_send_form_list.appendChild(chat_send_form_element);
        }
        for(i=0; i < message_return_btn.length; i++){
            message_return_btn[i].addEventListener("click", setReturnMessage)
        }

     //==============================================================|

        //ホームスケジュール関連
        var schedule_count_data = document.getElementById("home-schedule-count");
        if(schedule_count_data){
            var number = Number(schedule_count_data.getAttribute("data-schedule_count"));
        } 
        for(var i=0; i < number; i++){
            var schedule = document.getElementsByClassName(`box-${i}`);
            var schedule_height = 0;
            for(var s=0; s < schedule.length; s++){
                if(i%2 === 0){
                    schedule[s].style.backgroundColor = "rgba(29, 29, 29, 0.9)";
                } else {
                    schedule[s].style.backgroundColor = "rgba(37, 76, 109, 0.9)";
                }
                schedule_height += schedule[s].offsetHeight;
            }
            if(schedule_height < 40){
                var schedule_time = document.getElementById(`time-${i}`);
                var schedule_name = document.getElementById(`schedule-name-${i}`);
                schedule_time.style.display = "none";
                schedule_name.style.display = "none";
                for(var s=0; s < schedule.length; s++){
                    schedule[s].classList.add("need-details");
                    if(s === 0){
                        var schedule_details_element = document.createElement("p");
                        schedule_details_element.setAttribute("id", `schedule-details-${i}`);
                        schedule_details_element.setAttribute("class", `schedule-details`);
                        var schedule_details_text_1 = document.createTextNode(`${schedule_name.textContent}`);
                        var schedule_details_text_2 = document.createElement("br");
                        var schedule_details_text_3 = document.createTextNode(`${schedule_time.textContent}`);
                        schedule_details_element.appendChild(schedule_details_text_1);
                        schedule_details_element.appendChild(schedule_details_text_2);
                        schedule_details_element.appendChild(schedule_details_text_3);
                        schedule[0].appendChild(schedule_details_element);
                    }
                    schedule[s].addEventListener("mouseover", (event) => {
                        var schedule_number = (event.target.classList[0].replace(/[^0-9]/g, ''));
                        var schedule_details = document.getElementById(`schedule-details-${schedule_number}`);
                        schedule_details.style.display = "block";
                    }, false);
                    schedule[s].addEventListener("mouseleave", (event) => {
                        var schedule_number = (event.target.classList[0].replace(/[^0-9]/g, ''));
                        var schedule_details = document.getElementById(`schedule-details-${schedule_number}`);
                        schedule_details.style.display = "none";
                    }, false);
                }
            }
        }

        //スケジュール編集関連
        for(var i=0; i < number; i++){
            var schedule = document.getElementsByClassName(`edit-schedule-${i}`);
            for(var s=0; s < schedule.length; s++){
                if(i%2 == 0){
                    schedule[s].style.backgroundColor = "rgba(29, 29, 29, 0.9)";
                } else {
                    schedule[s].style.backgroundColor = "rgba(37, 76, 109, 0.9)";
                }
            }
        }

     //==============================================================|

        //ホームチャット送信先ユーザー選択ボックス関連
        //新規グループ作成選択ボックス関連

        //リスト展開
        var group_selector = document.getElementsByClassName("group-container");
        const openList = (event) => {
            if(!event.target.matches(".group-check")){
                var user_list = event.target.nextElementSibling;
                if(user_list.style.display == "block"){
                    user_list.style.display = "none";
                } else {
                    user_list.style.display = "block";
                }
            }
        }
        for(var i=0; i < group_selector.length;i++){
            group_selector[i].addEventListener("click", openList);
        }

        //ユーザー個別選択
        var click_user_selectors = document.getElementsByClassName("user-selector");
        const clickUserSelector = (event) => {
            var chat_send_list_container = document.getElementById("send-list");
            var event_parent = event.target.parentNode;
            var event_parent2 = event_parent.parentNode;
            var container = event_parent2.parentNode;
            var checking_box = event.target.getElementsByTagName("input")[0];
            var check_user_id = checking_box.value;
            var user_select_to_check = container.getElementsByClassName(`user-selector-${check_user_id}`);
            for(num=0; num < user_select_to_check.length;num++){
                var user_checkbox = user_select_to_check[num].getElementsByTagName("input")[0];
                var user_list = user_select_to_check[num].parentNode;
                var user_list_selectors = user_list.children;
                var group_div = user_list.previousElementSibling;
                var group_div_checkbox = group_div.getElementsByTagName("input")[0];
                var selector_count = 0;
                if(user_checkbox.checked){
                    user_checkbox.checked = false;
                    user_select_to_check[num].style.color = "white";
                    user_select_to_check[num].style.backgroundColor = "";
                    user_select_to_check[num].style.fontWeight = "";
                    for(var list_number=0; list_number < user_list_selectors.length;list_number++){
                        if(user_list_selectors[list_number].getElementsByTagName("input")[0].checked){
                            selector_count = selector_count -1;
                        }
                        if(selector_count <= 0){
                            group_div_checkbox.checked = false;
                        }
                    }
                } else {
                    user_checkbox.checked = true;
                    user_select_to_check[num].style.color = "black";
                    user_select_to_check[num].style.backgroundColor = "white";
                    user_select_to_check[num].style.fontWeight = "bold";
                    for(var list_number=0; list_number < user_list_selectors.length;list_number++){
                        if(user_list_selectors[list_number].getElementsByTagName("input")[0].checked){
                            selector_count = selector_count +1;
                        } 
                        if(selector_count >= user_list_selectors.length){
                            group_div_checkbox.checked = true;
                        }
                    }
                }
            }
            if(container == chat_send_list_container){
                if(checking_box.checked){
                    var chat_send_user_list = document.getElementById("chat-send-user-list");
                    var send_user_element = document.createElement("li");
                    var send_user_element_text = document.createTextNode(`${event.target.textContent}`);
                    send_user_element.setAttribute("id", `send-selected-user-${check_user_id}`);
                    send_user_element.setAttribute("class", "send-selected-users");
                    send_user_element.appendChild(send_user_element_text);
                    chat_send_user_list.appendChild(send_user_element);
                    var chat_send_form_list = document.getElementById("chat-send-users-form-list");
                    var chat_send_form_element = document.createElement("input");
                    chat_send_form_element.setAttribute("type", "hidden");
                    chat_send_form_element.setAttribute("name", "general_message_send_users[]");
                    chat_send_form_element.setAttribute("id", `chat-send-users-form-${check_user_id}`);
                    chat_send_form_element.value = check_user_id;
                    chat_send_form_list.appendChild(chat_send_form_element);
                } else {
                    var remove_send_user_element = document.getElementById(`send-selected-user-${check_user_id}`);
                    remove_send_user_element.remove();
                    var remove_send_user_form_element = document.getElementById(`chat-send-users-form-${check_user_id}`);
                    remove_send_user_form_element.remove();
                }
            }
        }
        for(var i=0; i < click_user_selectors.length; i++){
            click_user_selectors[i].addEventListener("click", clickUserSelector);
        }

        //一括選択
        var click_group_checkbox = document.getElementsByClassName("group-check");
        const clickGroupCheck = (event) => {
            var chat_send_list_container = document.getElementById("send-list");
            var event_parent = event.target.parentNode;
            var event_parent2 = event_parent.parentNode;
            var container = event_parent2.parentNode;

            var group_div = event.target.parentNode;
            var user_list = group_div.nextElementSibling;
            var user_list_selectors = user_list.children;
            for(var num=0; num < user_list_selectors.length;num++){
                var user_checkbox = user_list_selectors[num].getElementsByTagName("input")[0];
                var check_user_id = user_checkbox.value;
                var user_select_to_check = container.getElementsByClassName(`user-selector-${check_user_id}`);
                for(var user_selector_num=0; user_selector_num < user_select_to_check.length;user_selector_num++){
                    var common_user_checkbox = user_select_to_check[user_selector_num].getElementsByTagName("input")[0];
                    var common_user_list = user_select_to_check[user_selector_num].parentNode;
                    var user_selectors = common_user_list.children;
                    var group_div = common_user_list.previousElementSibling;
                    var group_div_checkbox = group_div.getElementsByTagName("input")[0];
                    var selector_count = 0;
                    if(!event.target.checked){
                        common_user_checkbox.checked = false;
                        user_select_to_check[user_selector_num].style.color = "white";
                        user_select_to_check[user_selector_num].style.backgroundColor = "";
                        user_select_to_check[user_selector_num].style.fontWeight = "";
                        if(container == chat_send_list_container){
                            var remove_send_user_element = document.getElementById(`send-selected-user-${check_user_id}`);
                            if(remove_send_user_element){
                                remove_send_user_element.remove();
                                var remove_send_user_form_element = document.getElementById(`chat-send-users-form-${check_user_id}`);
                                remove_send_user_form_element.remove();
                            }
                        }
                    } else {
                        common_user_checkbox.checked = true;
                        user_select_to_check[user_selector_num].style.color = "black";
                        user_select_to_check[user_selector_num].style.backgroundColor = "white";
                        user_select_to_check[user_selector_num].style.fontWeight = "bold";
                        if(container == chat_send_list_container){
                            var add_send_user_element = document.getElementById(`send-selected-user-${check_user_id}`);
                            if(!add_send_user_element){
                                var chat_send_user_list = document.getElementById("chat-send-user-list");
                                var send_user_element = document.createElement("li");
                                var send_user_element_text = document.createTextNode(`${user_list_selectors[num].textContent}`);
                                send_user_element.setAttribute("id", `send-selected-user-${check_user_id}`);
                                send_user_element.setAttribute("class", "send-selected-users");
                                send_user_element.appendChild(send_user_element_text);
                                chat_send_user_list.appendChild(send_user_element);
                                var chat_send_form_list = document.getElementById("chat-send-users-form-list");
                                var chat_send_form_element = document.createElement("input");
                                chat_send_form_element.setAttribute("type", "hidden");
                                chat_send_form_element.setAttribute("name", "general_message_send_users[]");
                                chat_send_form_element.setAttribute("id", `chat-send-users-form-${check_user_id}`);
                                chat_send_form_element.value = check_user_id;
                                chat_send_form_list.appendChild(chat_send_form_element);
                            }
                        }
                    }
                    for(var list_number=0; list_number < user_selectors.length;list_number++){
                        if(!event.target.checked){
                            if(user_selectors[list_number].getElementsByTagName("input")[0].checked){
                                selector_count = selector_count -1;
                            }
                            if(selector_count <= 0){
                                group_div_checkbox.checked = false;
                            }
                        } else {
                            if(user_selectors[list_number].getElementsByTagName("input")[0].checked){
                                selector_count = selector_count +1;
                            }
                            if(selector_count >= user_selectors.length){
                                group_div_checkbox.checked = true;
                            }
                        }
                    }
                }
            }
        }
        for(var i=0; i < click_group_checkbox.length;i++){
            click_group_checkbox[i].addEventListener("click", clickGroupCheck);
        }

    } else if(meeting_new_form){
        console.log("meeting_new");
     //==============================================================|
        //ミーティングルーム作成画面

        var modal = document.getElementById("Modal");
        document.getElementById("meeting_room_start_at_1i").remove();
        document.getElementById("meeting_room_start_at_2i").remove();
        document.getElementById("meeting_room_start_at_3i").remove();
        document.getElementById("meeting_room_finish_at_1i").remove();
        document.getElementById("meeting_room_finish_at_2i").remove();
        document.getElementById("meeting_room_finish_at_3i").remove();
        
        //ミーティングルーム作成ユーザーリスト関連

        var entries_error = document.getElementsByClassName("entries-error")[0];

        //リスト展開
        var new_room_select_group = document.getElementsByClassName("entry-select-group");
        const openNewRoomList = (event) => {
            if(!event.target.matches(".entry-group-check")){
                var group_number = (event.target.id).replace(/[^0-9]/g, '');
                var user_list = document.getElementById(`entry-select-list-${group_number}`);
                if(user_list.style.display == "block"){
                    user_list.style.display = "none";
                } else {
                    user_list.style.display = "block";
                }
            }
        }
        for(var i=0; i < new_room_select_group.length;i++){
            new_room_select_group[i].addEventListener("click", openNewRoomList);
        }

        //ユーザー個別選択
        var new_room_user_list_content = document.getElementsByClassName("entry-select-user-content");
        const selectNewRoomUser = (event) => {
            if(entries_error){
                entries_error.style.display = "none";
            }
            var user_list_check = event.target.getElementsByTagName("input");
            var check_user_id = user_list_check[0].value;
            var check_box_user_elements = document.getElementsByClassName(`user_ids_${check_user_id}`);
            for(var num=0; num < check_box_user_elements.length;num++){
                var check_box_user_element_parent = check_box_user_elements[num].parentNode;
                var group_list_ul_element = check_box_user_element_parent.parentNode;
                var group_list_li_elements = group_list_ul_element.children;
                var group_list_number = (group_list_ul_element.id).replace(/[^0-9]/g, "");
                var group_header = document.getElementById(`entry-select-group-${group_list_number}`);
                var group_header_checkbox = group_header.getElementsByTagName("input");
                var list_count = 0;
                if(check_box_user_elements[num].checked){
                    check_box_user_elements[num].checked = false;
                    check_box_user_element_parent.style.color = "white";
                    check_box_user_element_parent.style.backgroundColor = "";
                    check_box_user_element_parent.style.fontWeight = "";
                    for(var list_number=0; list_number < group_list_li_elements.length; list_number++){
                        if(group_list_li_elements[list_number].getElementsByTagName("input")[0].checked){
                            list_count = list_count -1;
                        }
                        if(list_count <= 0){
                            group_header_checkbox[0].checked = false;
                        }
                    }
                }else {
                    check_box_user_elements[num].checked = true;
                    check_box_user_element_parent.style.color = "black";
                    check_box_user_element_parent.style.backgroundColor = "white";
                    check_box_user_element_parent.style.fontWeight = "bold";
                    for(var list_number=0; list_number < group_list_li_elements.length; list_number++){
                        if(group_list_li_elements[list_number].getElementsByTagName("input")[0].checked){
                            list_count = list_count + 1;
                        }
                        if(list_count >= group_list_li_elements.length){
                            group_header_checkbox[0].checked = true;
                        }
                    }
                }
            }
            if(user_list_check[0].checked){
                var entry_selected_container = document.getElementById("selected-users");
                var entry_selected_user_li = document.createElement("li");
                entry_selected_user_li.setAttribute("id", `entry-user-${check_user_id}`);
                entry_selected_user_li.innerHTML = `${event.target.textContent}`;
                entry_selected_container.appendChild(entry_selected_user_li);
                var entry_selected_user_form = document.getElementById("entry-selected-user-forms");
                var entry_selected_form = document.createElement("input");
                entry_selected_form.setAttribute("type", "hidden");
                entry_selected_form.setAttribute("name", "meeting_room[room_entry_users][]");
                entry_selected_form.setAttribute("id", `room_entry_user_${check_user_id}`);
                entry_selected_form.setAttribute("value", `${check_user_id}`);
                entry_selected_user_form.appendChild(entry_selected_form);
            } else {
                var remove_element = document.getElementById(`entry-user-${check_user_id}`);
                var remove_form_element = document.getElementById(`room_entry_user_${check_user_id}`);
                remove_element.remove();
                remove_form_element.remove();
            }
        }
        for(var i=0; i < new_room_user_list_content.length;i++){
            new_room_user_list_content[i].addEventListener("click", selectNewRoomUser);
        }

        //一括選択
        var new_room_group_list_check = document.getElementsByClassName("entry-group-check");
        const selectNewRoomGroup = (event) => {
            if(entries_error){
                entries_error.style.display = "none";
            }
            var group_number = (event.target.parentNode.id).replace(/[^0-9]/g, "");
            var user_list = document.getElementById(`entry-select-list-${group_number}`);
            var user_list_contents = user_list.getElementsByTagName("li");
            for(var num=0; num < user_list_contents.length;num++){
                var user_list_check = user_list_contents[num].getElementsByTagName("input");
                var check_user_id = user_list_check[0].value;
                var check_box_user_elements = document.getElementsByClassName(`user_ids_${check_user_id}`);
                for(var user_box_num=0; user_box_num < check_box_user_elements.length;user_box_num++){
                    var check_box_user_element_parent = check_box_user_elements[user_box_num].parentNode;
                    if(!event.target.checked){
                        check_box_user_elements[user_box_num].checked = false;
                        check_box_user_element_parent.style.color = "white";
                        check_box_user_element_parent.style.backgroundColor = "";
                        check_box_user_element_parent.style.fontWeight = "";
                    } else {
                        check_box_user_elements[user_box_num].checked = true;
                        check_box_user_element_parent.style.color = "black";
                        check_box_user_element_parent.style.backgroundColor = "white";
                        check_box_user_element_parent.style.fontWeight = "bold";
                    }
                    var group_list_ul_element = check_box_user_element_parent.parentNode;
                    var group_list_li_elements = group_list_ul_element.children;
                    var group_list_number = (group_list_ul_element.id).replace(/[^0-9]/g, "");
                    var group_header = document.getElementById(`entry-select-group-${group_list_number}`);
                    var group_header_checkbox = group_header.getElementsByTagName("input");
                    var list_count = 0;
                    for(var list_number=0; list_number < group_list_li_elements.length;list_number++){
                        if(!event.target.checked){
                            if(group_list_li_elements[list_number].getElementsByClassName("input").checked){
                                list_count = list_count -1;
                            }
                            if(list_count <= 0){
                                group_header_checkbox[0].checked = false;
                            }   
                        } else {
                            if(group_list_li_elements[list_number].getElementsByTagName("input")[0].checked){
                                list_count = list_count + 1;
                            }
                            if(list_count >= group_list_li_elements.length){
                                group_header_checkbox[0].checked = true;
                            }
                        }
                    }
                }
                var remove_element = document.getElementById(`entry-user-${check_user_id}`);
                if(!remove_element){
                    var entry_selected_container = document.getElementById("selected-users");
                    var entry_selected_user_li = document.createElement("li");
                    entry_selected_user_li.setAttribute("id", `entry-user-${check_user_id}`);
                    entry_selected_user_li.innerHTML = `${user_list_contents[num].textContent}`;
                    entry_selected_container.appendChild(entry_selected_user_li);
                    var entry_selected_user_form = document.getElementById("entry-selected-user-forms");
                    var entry_selected_form = document.createElement("input");
                    entry_selected_form.setAttribute("type", "hidden");
                    entry_selected_form.setAttribute("name", "meeting_room[room_entry_users][]");
                    entry_selected_form.setAttribute("id", `room_entry_user_${check_user_id}`);
                    entry_selected_form.setAttribute("value", `${check_user_id}`);
                    entry_selected_user_form.appendChild(entry_selected_form);
                } else if(!event.target.checked) {
                    var remove_form_element = document.getElementById(`room_entry_user_${check_user_id}`);
                    remove_element.remove();
                    remove_form_element.remove();
                }
            }
        }
        for(var i=0; i < new_room_group_list_check.length;i++){
            new_room_group_list_check[i].addEventListener("click", selectNewRoomGroup);
        }
        
    } else if(meeting_room) {
        console.log("meeting_room");
     //==============================================================|
        // タイマー関連
        // タイマー表示切替
        var timer_btn = document.getElementById("header-time-btn");
        var timer_container = document.getElementById("timer-container");
        var btn_time = document.getElementById("btn-time");

        timer_btn.onclick = () => {
            if(timer_btn.classList.contains("active")){
                timer_btn.style.background = "black";
                timer_btn.style.color = "white";
                timer_btn.classList.remove("active");
                timer_container.style.display = "none";
            } else {
                timer_btn.style.background = "white";
                timer_btn.style.color = "black";
                timer_btn.classList.add("active");
                timer_container.style.display = "inline-block";
                btn_time.textContent = "Timer";
            }
        }

        var timer = document.getElementById("timer");
        var timer_start = document.getElementById("timer-start");
        var timer_stop = document.getElementById("timer-stop");
        var timer_reset = document.getElementById("timer-reset");
        var timer_start_time = document.getElementById("timer-start-time");
        var timer_schedule_link = document.getElementById("timer-schedule-link");

        // タイマー桁合わせ
        function time_exchange(time){
            var num = String(time);
            if(num.length === 1){
                num = "0" + num;
            }
            return num;
        }

        // タイマー変数
        var stock_start_time;
        var stock_end_time;
        var timer_n = 0;
        var timer_s = 0;
        var timer_s_ex = 0;
        var timer_m = 0;
        var timer_m_ex = 0;
        var timer_h = 0;
        var timer_interval;

        // タイマースタート時
        timer_start.onclick = () => {
            timer_start.style.display = "none";
            timer_stop.style.display = "block";
            var now = new Date();
            var hours = time_exchange(now.getHours());
            var minutes = time_exchange(now.getMinutes());
            if (timer_start_time.textContent === "TIME"){
                stock_start_time = `${hours}：${minutes}`;
                timer_start_time.textContent = `${hours}：${minutes} ~ 測定中`;
            }
            timer_interval = setInterval(() => {
                timer_n = timer_n + 1;
                if(Number.isInteger(timer_n / 60)){
                    timer_s = "00"; // 8進数によるコンパイルエラー対策のためString型
                    timer_m = (timer_n / 60) - timer_m_ex;
                    timer_s_ex = timer_s_ex + 60;
                } else {
                    timer_s = timer_n - timer_s_ex;
                }
                if(Number.isInteger(timer_n / 3600)){
                    timer_m = "00";　// 8進数によるコンパイルエラー対策のためString型
                    timer_h = timer_n / 3600;
                    timer_m_ex = timer_m_ex + 60;
                }
                timer.textContent = `${time_exchange(timer_h)}：${time_exchange(timer_m)}：${time_exchange(timer_s)}`;
                if(timer_container.style.display == "none"){
                    btn_time.textContent = `${time_exchange(timer_h)}：${time_exchange(timer_m)}：${time_exchange(timer_s)}`;
                }
            }, 1000);
        }

        // タイマーストップ時
        timer_stop.onclick = () => {
            timer_stop.style.display = "none";
            timer_start.style.display = "block";
            clearInterval(timer_interval);
            var now = new Date();
            var hours = time_exchange(now.getHours());
            var minutes = time_exchange(now.getMinutes());
            stock_end_time = `${hours}：${minutes}`;
            timer_start_time.textContent = `${stock_start_time} ~ ${hours}：${minutes}`;
            timer_schedule_link.href = `/schedules/add_timer?end_time=${stock_end_time}&start_time=${stock_start_time}`;
        }

        // タイマーリセット時
        timer_reset.onclick = () => {
            timer_n = 0;
            timer_s = 0;
            timer_s_ex = 0;
            timer_m = 0;
            timer_m_ex = 0;
            timer_h = 0;
            timer_start_time.textContent = "TIME";
            timer.textContent = "00：00：00";
            clearInterval(timer_interval);
            timer_stop.style.display = "none";
            timer_start.style.display = "block";
            timer_schedule_link.href = "/schedules/add_timer?end_time=&start_time=";
        }
    } else if(management_user_page) {

        // ユーザーマネージメントページ　スケジュール
        var schedule_count_data = document.getElementById("home-schedule-count");
        if(schedule_count_data){
            var number = Number(schedule_count_data.getAttribute("data-schedule_count"));
        } 
        for(var i=0; i < number; i++){
            var schedule = document.getElementsByClassName(`box-${i}`);
            var schedule_height = 0;
            for(var s=0; s < schedule.length; s++){
                if(i%2 === 0){
                    schedule[s].style.backgroundColor = "rgba(29, 29, 29, 0.9)";
                } else {
                    schedule[s].style.backgroundColor = "rgba(37, 76, 109, 0.9)";
                }
                schedule_height += schedule[s].offsetHeight;
            }
            if(schedule_height < 40){
                var schedule_time = document.getElementById(`time-${i}`);
                var schedule_name = document.getElementById(`schedule-name-${i}`);
                schedule_time.style.display = "none";
                schedule_name.style.display = "none";
                for(var s=0; s < schedule.length; s++){
                    schedule[s].classList.add("need-details");
                    if(s === 0){
                        var schedule_details_element = document.createElement("p");
                        schedule_details_element.setAttribute("id", `schedule-details-${i}`);
                        schedule_details_element.setAttribute("class", `schedule-details`);
                        var schedule_details_text_1 = document.createTextNode(`${schedule_name.textContent}`);
                        var schedule_details_text_2 = document.createElement("br");
                        var schedule_details_text_3 = document.createTextNode(`${schedule_time.textContent}`);
                        schedule_details_element.appendChild(schedule_details_text_1);
                        schedule_details_element.appendChild(schedule_details_text_2);
                        schedule_details_element.appendChild(schedule_details_text_3);
                        schedule[0].appendChild(schedule_details_element);
                    }
                    schedule[s].addEventListener("mouseover", (event) => {
                        var schedule_number = (event.target.classList[0].replace(/[^0-9]/g, ''));
                        var schedule_details = document.getElementById(`schedule-details-${schedule_number}`);
                        schedule_details.style.display = "block";
                    }, false);
                    schedule[s].addEventListener("mouseleave", (event) => {
                        var schedule_number = (event.target.classList[0].replace(/[^0-9]/g, ''));
                        var schedule_details = document.getElementById(`schedule-details-${schedule_number}`);
                        schedule_details.style.display = "none";
                    }, false);
                }
            }
        }

    }
});
