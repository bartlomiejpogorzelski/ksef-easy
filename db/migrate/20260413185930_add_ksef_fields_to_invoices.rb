class AddKsefFieldsToInvoices < ActiveRecord::Migration[8.0]
  def change
    add_column :invoices, :ksef_reference_number, :string
    add_column :invoices, :ksef_number, :string
    add_column :invoices, :ksef_status, :string, default: "draft"
    add_column :invoices, :ksef_sent_at, :datetime
    add_column :invoices, :ksef_error_message, :text
    add_column :invoices, :ksef_xml, :text
  end
end