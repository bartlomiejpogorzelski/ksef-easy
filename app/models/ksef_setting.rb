class KsefSetting < ApplicationRecord
  belongs_to :user
  belongs_to :team, optional: true

  validates :nip, presence: true, length: { is: 10 }, numericality: { only_integer: true }
  validates :environment, presence: true, inclusion: { in: %w[test production] }
  validates :token, presence: true, if: -> { environment == "production" } # token wymagany w prod

  enum :environment, { test: "test", production: "production" }, suffix: true
end
