class Team < ApplicationRecord
  include Teams::Base
  include Webhooks::Outgoing::TeamSupport

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  belongs_to :owner, class_name: "User", optional: true
  # 🚅 add concerns above.

  # 🚅 add belongs_to associations above.

  has_many :invoices, dependent: :destroy
  # 🚅 add has_many associations above.

  # 🚅 add oauth providers above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # 🚅 add methods above.
end
