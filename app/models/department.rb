class Department < ApplicationRecord

  # Departmentモデル バリデーション
  validates :name, presence: true, length: { maximum: 15 }, uniqueness: { case_sensitive: false }

  # User関連アソシエーション
  has_many :users
end
