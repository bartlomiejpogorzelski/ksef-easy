json.extract! invoice,
  :id,
  :team_id,
  :number,
  :issue_date,
  :sale_date,
  :payment_date,
  :netto,
  :vat_rate,
  :vat,
  :brutto,
  :status,
  :buyer_nip,
  :buyer_name,
  :seller,
  :description,
  # 🚅 super scaffolding will insert new fields above this line.
  :created_at,
  :updated_at

# Załącznik (jeśli istnieje)
if invoice.document.attached?
  json.document do
    json.filename invoice.document.filename
    json.byte_size invoice.document.byte_size
    json.url rails_blob_url(invoice.document)
  end
end

# 🚅 super scaffolding will insert file-related logic above this line.
