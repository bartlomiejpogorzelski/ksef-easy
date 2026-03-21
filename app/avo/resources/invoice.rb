class Avo::Resources::Invoice < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :team, as: :belongs_to
    field :number, as: :text
    field :issue_date, as: :date
    field :sale_date, as: :date
    field :payment_date, as: :date
    field :netto, as: :number
    field :vat_rate, as: :number
    field :vat, as: :number
    field :brutto, as: :number
    field :status, as: :text
    field :buyer_nip, as: :text
    field :buyer_name, as: :text
    field :seller, as: :text
    field :description, as: :textarea
  end
end
