class User < ApplicationRecord
  include Users::Base
  include Roles::User

  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships
  has_one :ksef_setting, dependent: :destroy

  accepts_nested_attributes_for :ksef_setting, update_only: true

  # 🚅 add concerns above.

  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add oauth providers above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # 🚅 add methods above.
end
