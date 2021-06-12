require "rails_helper"

RSpec.describe ContactGroupRelation, type: :model do
  let!(:dept) { create(:human_resources_dept) }
  let!(:user) { create(:user, department_id: dept.id) }
  let!(:other_user) { create(:other_user, department_id: dept.id) }
  let!(:contact_group) { create(:contact_group, user_id: user.id) }
  let(:contact_group_relation) { contact_group.contact_group_relations.build(user_id: other_user.id) }

  it "全てのカラムが正常" do
    expect(contact_group_relation).to be_valid
  end

  it "ユーザーIDが空の場合" do
    contact_group_relation.user_id = ""
    expect(contact_group_relation).not_to be_valid
  end

  it "コンタクトグループIDが空の場合" do
    contact_group_relation.contact_group_id = ""
    expect(contact_group_relation).not_to be_valid
  end

  it "ユーザーIDとコンタクトグループIDの組み合わせが既に存在する場合" do
    contact_group.contact_group_relations.create(user_id: other_user.id)
    expect(contact_group_relation).not_to be_valid
  end
end
