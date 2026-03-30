require 'rails_helper'

RSpec.describe "Account::Settings::Ksefs", type: :request do
  describe "GET /edit" do
    it "returns http success" do
      get "/account/settings/ksef/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/account/settings/ksef/update"
      expect(response).to have_http_status(:success)
    end
  end

end
