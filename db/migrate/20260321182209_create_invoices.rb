class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :team, null: false, foreign_key: true
      t.string :number
      t.date :issue_date
      t.date :sale_date
      t.date :payment_date
      t.integer :netto
      t.integer :vat_rate
      t.integer :vat
      t.integer :brutto
      t.string :status
      t.string :buyer_nip
      t.string :buyer_name
      t.string :seller
      t.text :description

      t.timestamps
    end
  end
end
