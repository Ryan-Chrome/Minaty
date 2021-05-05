require 'rails_helper'

# ユーザーモデル関連テスト
RSpec.describe User, type: :model do
    
    # バリデーション関連
    context "Validation" do

        let(:user){ FactoryBot.build(:user) }

        # 全てのカラムが正の場合
        it "is valid with a name and email and assignment and password" do
            expect(user).to be_valid
        end

        # 名前が空の場合
        it "is invalid without a name" do
            user.name = ""
            expect(user).not_to be_valid
        end

        # 名前が11文字以上の場合
        it "is invalid when name is 11 characters" do
            user.name = "#{"a" * 11}"
            expect(user).not_to be_valid
        end

        # メールアドレスが空の場合
        it "is invalid without a email" do
            user.email = ""
            expect(user).not_to be_valid
        end

        # メールアドレスが不正な文字列の場合
        it "is invalid when a email is incorrect" do
            user.email = "textcom"
            expect(user).not_to be_valid
        end

        # 所属が空の場合
        it "is invalid without a department" do
            user.department = ""
            expect(user).not_to be_valid
        end

        # パスワードが空の場合
        it "is invalid without a password" do
            user.password = ""
            expect(user).not_to be_valid
        end

        # パスワード半角英数字じゃない場合
        it "is invalid when a password(japanase) incorrect" do
            user.password = "テストパスワード"
            expect(user).not_to be_valid
        end

        # パスワードが5文字以下の場合
        it "is invalid when a password is 5 characters" do
            user.password = "fooba"
            expect(user).not_to be_valid
        end

        # 確認パスワードが空の場合
        it "is invalid without a password_confirmation" do
            user.password_confirmation = ""
            expect(user).not_to be_valid
        end

        # 確認パスワード違う場合
        it "is invalid when a password_confirmation is incorrect" do
            user.password_confirmation = "password"
            expect(user).not_to be_valid
        end

    end

    # アソシエーション関連
    context "Association" do

        let!(:user){ create(:user) }
        let!(:other_user){ create(:other_user) }
        let!(:meeting_room){ create(:meeting_room) }

        # ユーザー削除時　スケジュール削除
        it "destroy with destroy schedule" do
            user.schedules.create(name: "会議", start_at: "12:00", finish_at: "13:00", work_on: Date.today)
            expect { user.destroy }.to change{ Schedule.count }.by(-1)
            sleep 0.5 #スリープないと次のテスト失敗する
        end

        # ユーザー削除時　ジェネラルメッセージ削除
        it "destroy with destroy general_message" do
            user.general_messages.create(content: "テスト")
            expect { user.destroy }.to change{ GeneralMessage.count }.by(-1)
            sleep 0.5 #スリープないと次のテスト失敗する
        end

        # ユーザー削除時　ジェネラルメッセージリレーション削除(受信側のユーザーの場合)
        it "destroy with destroy reverse_message_relation" do
            general_message = user.general_messages.create(content: "テスト")
            general_message.general_message_relations.create(user_id: user.id, receive_user_id: other_user.id)
            expect { other_user.destroy }.to change{ GeneralMessageRelation.count }.by(-1)
            sleep 0.5 #スリープないと次のテスト失敗する
        end

        # ユーザー削除時　コンタクトグループ削除
        it "destroy with destroy contact_group" do
            user.contact_groups.create(name: "テストグループ")
            expect { user.destroy }.to change{ ContactGroup.count }.by(-1)
            sleep 0.5 #スリープないと次のテスト失敗する
        end

        # ユーザー削除時　コンタクトグループリレーション削除
        it "destroy with destroy contact_group_relation" do
            contact_group = user.contact_groups.create(name: "テストグループ")
            contact_group.contact_group_relations.create(user_id: other_user.id)
            expect { other_user.destroy }.to change{ ContactGroupRelation.count }.by(-1)
            sleep 0.5 #スリープないと次のテスト失敗する
        end

        # ユーザー削除時　ルームメッセージ削除
        it "destroy with destroy room_message" do
            room_message = meeting_room.room_messages.create(user_id: user.id, content: "テスト")
            expect { user.destroy }.to change{ RoomMessage.count }.by(-1)
            sleep 0.5 #スリープないと次のテスト失敗する
        end

        # ユーザー削除時　勤怠データ削除
        it "destroy with destroy attendance" do
            attendance = user.attendances.create(work_on: Date.today, arrived_at: DateTime.now)
            expect { user.destroy }.to change{ Attendance.count }.by(-1)
            sleep 0.5 #スリープないと次のテスト失敗する
        end

        # ユーザー削除時　有給データ削除
        it "destroy with destroy paid_holiday" do
            paid_holiday = user.paid_holidays.create(holiday_on: Date.today, reason: "私用")
            expect { user.destroy }.to change{ PaidHoliday.count }.by(-1)
            sleep 0.5 #スリープないと次のテスト失敗する
        end

    end

end