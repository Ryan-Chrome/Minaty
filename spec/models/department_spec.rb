require "rails_helper"

RSpec.describe Department, type: :model do

  # バリデーション関連
  describe "Validation" do
    let(:department) { Department.new(name: "人事部") }

    it "全てのカラムが正常" do
      expect(department).to be_valid
    end

    it "部署名が空の場合" do
      department.name = ""
      expect(department).not_to be_valid
    end

    it "部署名が15文字以上の場合" do
      department.name = "#{"a" * 16}"
      expect(department).not_to be_valid
    end

    it "部署名が既に存在している場合" do
      Department.create(name: "人事部")
      expect(department).not_to be_valid
    end
  end
end
