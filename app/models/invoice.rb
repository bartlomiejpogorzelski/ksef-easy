class Invoice < ApplicationRecord
  belongs_to :team
  # 🚅 add concerns above.

  # 🚅 add attribute accessors above.

  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.
  has_one_attached :document
  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  validates :number, presence: true
  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # 🚅 add methods above.
  enum :status, {
    draft: "draft",
    sent: "sent",
    paid: "paid",
    overdue: "overdue",
    rejected: "rejected"
  }, prefix: true
end
