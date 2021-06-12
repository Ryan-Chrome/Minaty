require "rails_helper"

# ユーザーモデル関連テスト
RSpec.describe User, type: :model do
  let!(:dept) { create(:human_resources_dept) }

  # バリデーション関連
  context "Validation" do
    let(:user) { build(:user, department_id: dept.id) }

    it "全てのカラムが正常" do
      expect(user).to be_valid
    end

    it "名前が空の場合" do
      user.name = ""
      expect(user).not_to be_valid
    end

    it "名前が10文字より長い場合" do
      user.name = "#{"a" * 11}"
      expect(user).not_to be_valid
    end

    it "メールアドレスが空の場合" do
      user.email = ""
      expect(user).not_to be_valid
    end

    it "メールアドレスが不正な文字列の場合" do
      user.email = "textcom"
      expect(user).not_to be_valid
    end

    it "部署IDが空の場合" do
      user.department_id = ""
      expect(user).not_to be_valid
    end

    it "パスワードが空の場合" do
      user.password = ""
      expect(user).not_to be_valid
    end

    it "パスワードが半角英数字でない場合" do
      user.password = "テストパスワード"
      expect(user).not_to be_valid
    end

    it "パスワードが6文字より短い場合" do
      user.password = "fooba"
      expect(user).not_to be_valid
    end

    it "確認パスワードが空の場合" do
      user.password_confirmation = ""
      expect(user).not_to be_valid
    end

    it "確認パスワードが違う場合" do
      user.password_confirmation = "password"
      expect(user).not_to be_valid
    end
  end

  # アソシエーション関連
  context "Association" do
    let!(:user) { create(:user, department_id: dept.id) }
    let!(:other_user) { create(:other_user, department_id: dept.id) }
    let!(:meeting_room) { create(:meeting_room) }

    it "ユーザー削除時、スケジュール削除" do
      user.schedules.create(name: "会議", start_at: "12:00", finish_at: "13:00", work_on: Date.today)
      expect { user.destroy }.to change { Schedule.count }.by(-1)
      sleep 0.5 #スリープないと次のテスト失敗する
    end

    it "ユーザー削除時、メッセージ削除" do
      user.general_messages.create(content: "テスト")
      expect { user.destroy }.to change { GeneralMessage.count }.by(-1)
      sleep 0.5 #スリープないと次のテスト失敗する
    end

    it "ユーザー削除時、メッセージリレーション削除(受信側のユーザー)" do
      general_message = user.general_messages.create(content: "テスト")
      general_message.receive_users << other_user
      expect { other_user.destroy }.to change { GeneralMessageRelation.count }.by(-1)
      sleep 0.5 #スリープないと次のテスト失敗する
    end

    it "ユーザー削除時、コンタクトグループ削除" do
      user.contact_groups.create(name: "テストグループ")
      expect { user.destroy }.to change { ContactGroup.count }.by(-1)
      sleep 0.5 #スリープないと次のテスト失敗する
    end

    it "ユーザー削除時、ルームメッセージ削除" do
      room_message = meeting_room.room_messages.create(user_id: user.id, content: "テスト")
      expect { user.destroy }.to change { RoomMessage.count }.by(-1)
      sleep 0.5 #スリープないと次のテスト失敗する
    end

    it "ユーザー削除時、勤怠データ削除" do
      attendance = user.attendances.create(work_on: Date.today, arrived_at: DateTime.now)
      expect { user.destroy }.to change { Attendance.count }.by(-1)
      sleep 0.5 #スリープないと次のテスト失敗する
    end

    it "ユーザー削除時、有給データ削除" do
      paid_holiday = user.paid_holidays.create(holiday_on: Date.today, reason: "私用")
      expect { user.destroy }.to change { PaidHoliday.count }.by(-1)
      sleep 0.5 #スリープないと次のテスト失敗する
    end
  end
end
