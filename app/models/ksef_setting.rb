class KsefSetting < ApplicationRecord
  belongs_to :user
  belongs_to :team, optional: true

  validates :nip,
            presence: true,
            length: { is: 10, message: "musi mieć dokładnie 10 cyfr" },
            numericality: { only_integer: true, message: "musi składać się wyłącznie z cyfr" }

  validates :environment,
            presence: true,
            inclusion: { in: %w[test production], message: "może być tylko 'test' lub 'production'" }

  validates :token,
            presence: { message: "jest wymagany w środowisku produkcyjnym" },
            if: -> { environment == "production" }

  validates :token,
            length: { minimum: 10, message: "jest za krótki (minimum 10 znaków)" },
            allow_blank: true   # puste w trybie testowym

  enum :environment, { test: "test", production: "production" }, suffix: true

  def masked_token
    return "" if token.blank?
    return token if token.length <= 12

    "••••••••••••" + token.last(8)
  end

  def token_present?
    token.present?
  end
end
