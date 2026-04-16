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
  # validates :ksef_status, inclusion: { in: ksef_statuses.keys.map(&:to_s) }

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

  enum :ksef_status, {
    draft: "draft",
    pending: "pending",
    sent: "sent",
    processed: "processed",
    error: "error"
  }, prefix: true, default: "draft"

  def send_to_ksef!
    return false if user.ksef_setting.blank? || user.ksef_setting.token.blank?

    client = Ksef::Api::Client.new(user.ksef_setting)

    result = client.send_invoice(self)

    if result[:success]
      update!(
        ksef_reference_number: result[:reference_number],
        ksef_status: :pending,
        ksef_sent_at: Time.current,
        ksef_error_message: nil
      )
      true
    else
      update!(
        ksef_status: :error,
        ksef_error_message: result[:message] || "Nieznany błąd"
      )
      false
    end
  end

  private

  def user
    team.memberships.first&.user || team.users.first
  end
  

  private

  def user
    # Zakładamy, że faktura należy do teamu, a team ma powiązanego użytkownika
    # Dostosuj jeśli masz inną relację (np. invoices należą bezpośrednio do usera)
    team.memberships.first&.user || team.users.first
  end
end
