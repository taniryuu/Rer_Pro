require 'rails_helper'

RSpec.describe "Leads::LeadsStatuses", type: :request do

  describe "GET /start" do
    it "returns http success" do
      get "/leads/leads_statuses/start"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /cancel" do
    it "returns http success" do
      get "/leads/leads_statuses/cancel"
      expect(response).to have_http_status(:success)
    end
  end

end
