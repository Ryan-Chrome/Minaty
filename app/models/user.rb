class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

	# devise設定
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

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
	validates :department, presence: true
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
	has_many :schedules, dependent: :destroy

	# ContactGroup関連アソシエーション
	has_many :contact_groups, dependent: :destroy
	has_many :contact_group_relations, dependent: :destroy

	# GeneralMessage関連アソシエーション
	has_many :general_messages, dependent: :destroy
	has_many :general_message_relations
	has_many :reverse_message_relations, class_name: 'GeneralMessageRelation', foreign_key: 'receive_user_id', dependent: :destroy

	# MeetingRoom関連アソシエーション
	has_many :entries, dependent: :destroy
	has_many :meeting_rooms, through: :entries
	has_many :room_messages, dependent: :destroy

	# Attendance関連アソシエーション
	has_many :attendances, dependent: :destroy

	# PaidHoliday関連アソシエーション
	has_many :paid_holidays, dependent: :destroy


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
