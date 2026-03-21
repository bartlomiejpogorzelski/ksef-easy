FactoryBot.define do
  factory :invoice do
    association :team
    number { "MyString" }
    issue_date { "2026-03-21" }
    sale_date { "2026-03-21" }
    payment_date { "2026-03-21" }
    netto { 1 }
    vat_rate { 1 }
    vat { 1 }
    brutto { 1 }
    status { "MyString" }
    buyer_nip { "MyString" }
    buyer_name { "MyString" }
    seller { "MyString" }
    description { "MyText" }
  end
end
