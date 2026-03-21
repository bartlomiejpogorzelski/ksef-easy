require "controllers/api/v1/test"

class Api::V1::InvoicesControllerTest < Api::Test
  setup do
    # See `test/controllers/api/test.rb` for common set up for API tests.

    @invoice = build(:invoice, team: @team)
    @other_invoices = create_list(:invoice, 3)

    @another_invoice = create(:invoice, team: @team)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @invoice.save
    @another_invoice.save

    @original_hide_things = ENV["HIDE_THINGS"]
    ENV["HIDE_THINGS"] = "false"
    Rails.application.reload_routes!
  end

  teardown do
    ENV["HIDE_THINGS"] = @original_hide_things
    Rails.application.reload_routes!
  end

  # This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
  # data we were previously providing to users _will_ break the test suite.
  def assert_proper_object_serialization(invoice_data)
    # Fetch the invoice in question and prepare to compare it's attributes.
    invoice = Invoice.find(invoice_data["id"])

    assert_equal_or_nil invoice_data["number"], invoice.number
    assert_equal_or_nil Date.parse(invoice_data["issue_date"]), invoice.issue_date
    assert_equal_or_nil Date.parse(invoice_data["sale_date"]), invoice.sale_date
    assert_equal_or_nil Date.parse(invoice_data["payment_date"]), invoice.payment_date
    assert_equal_or_nil invoice_data["netto"], invoice.netto
    assert_equal_or_nil invoice_data["vat_rate"], invoice.vat_rate
    assert_equal_or_nil invoice_data["vat"], invoice.vat
    assert_equal_or_nil invoice_data["brutto"], invoice.brutto
    assert_equal_or_nil invoice_data["status"], invoice.status
    assert_equal_or_nil invoice_data["buyer_nip"], invoice.buyer_nip
    assert_equal_or_nil invoice_data["buyer_name"], invoice.buyer_name
    assert_equal_or_nil invoice_data["seller"], invoice.seller
    assert_equal_or_nil invoice_data["description"], invoice.description
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal invoice_data["team_id"], invoice.team_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/teams/#{@team.id}/invoices", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    invoice_ids_returned = response.parsed_body.map { |invoice| invoice["id"] }
    assert_includes(invoice_ids_returned, @invoice.id)

    # But not returning other people's resources.
    assert_not_includes(invoice_ids_returned, @other_invoices[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/invoices/#{@invoice.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/invoices/#{@invoice.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    invoice_data = JSON.parse(build(:invoice, team: nil).api_attributes.to_json)
    invoice_data.except!("id", "team_id", "created_at", "updated_at")
    params[:invoice] = invoice_data

    post "/api/v1/teams/#{@team.id}/invoices", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/teams/#{@team.id}/invoices",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/invoices/#{@invoice.id}", params: {
      access_token: access_token,
      invoice: {
        number: "Alternative String Value",
        status: "Alternative String Value",
        buyer_nip: "Alternative String Value",
        buyer_name: "Alternative String Value",
        seller: "Alternative String Value",
        description: "Alternative String Value",
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @invoice.reload
    assert_equal @invoice.number, "Alternative String Value"
    assert_equal @invoice.status, "Alternative String Value"
    assert_equal @invoice.buyer_nip, "Alternative String Value"
    assert_equal @invoice.buyer_name, "Alternative String Value"
    assert_equal @invoice.seller, "Alternative String Value"
    assert_equal @invoice.description, "Alternative String Value"
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/invoices/#{@invoice.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("Invoice.count", -1) do
      delete "/api/v1/invoices/#{@invoice.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/invoices/#{@another_invoice.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
