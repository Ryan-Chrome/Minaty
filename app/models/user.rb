class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  # devise設定
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  # public_uid
  generate_public_uid

  def to_params
    public_uid
  end

  generate_public_uid generator: PublicUid::Generators::HexStringSecureRandom.new(16)

  # Userモデル　バリデーション
  validates :name, presence: true, length: { maximum: 10 }
  VALID_PASSWORD_REGEX = /\A[a-z0-9]+\z/i
  validate :password_validate
  validates :department_id, presence: true
  validates :kana, presence: true, length: { maximum: 25 }

  # Userモデル 作成時パスワードバリデーション
  def password_validate
    if password.present?
      matched = password.match(VALID_PASSWORD_REGEX)
      unless matched
        errors.add(:password, "半角英数字のみ有効です")
      end
    end
  end

  # Schedule関連アソシエーション
  has_many :schedules, dependent: :delete_all

  # ContactGroup関連アソシエーション
  has_many :contact_groups, dependent: :delete_all
  has_many :contact_group_relations, dependent: :delete_all
  has_many :belong_to_groups, through: :contact_group_relations, source: :contact_group

  # GeneralMessage関連アソシエーション
  has_many :general_messages, dependent: :delete_all
  has_many :general_message_relations, dependent: :delete_all
  has_many :receive_messages, through: :general_message_relations, source: :general_message

  # MeetingRoom関連アソシエーション
  has_many :entries, dependent: :delete_all
  has_many :meeting_rooms, through: :entries
  has_many :room_messages, dependent: :delete_all

  # Attendance関連アソシエーション
  has_many :attendances, dependent: :delete_all

  # PaidHoliday関連アソシエーション
  has_many :paid_holidays, dependent: :delete_all

  # Department関連アソシエーション
  belongs_to :department

  def update_with_admin_password(params, admin_user)
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if admin_user.valid_admin_user_password?(current_password)
        update(params)
      else
        assign_attributes(params)
        valid?
        errors.add(:current_password, current_password.blank? ? :blank : :invalid)
        false
      end
    clean_up_passwords
    result
  end

  def valid_admin_user_password?(password)
    Devise::Encryptor.compare(self.class, encrypted_password, password)
  end
end
