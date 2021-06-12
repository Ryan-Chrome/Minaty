require "rails_helper"

RSpec.describe GeneralMessageRelation, type: :model do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:message) { create(:general_message, user_id: user.id) }
  let(:general_message_relation) { message.general_message_relations.build(user_id: other_user.id) }

  it "全てのカラムが正常" do
    expect(general_message_relation).to be_valid
  end

  it "ユーザーIDが空の場合" do
    general_message_relation.user_id = ""
    expect(general_message_relation).not_to be_valid
  end

  it "メッセージIDが空の場合" do
    general_message_relation.general_message_id = ""
    expect(general_message_relation).not_to be_valid
  end

  it "ユーザーIDとメッセージIDの組み合わせが既に存在する場合" do
    message.receive_users << other_user
    expect(general_message_relation).not_to be_valid
  end
end
