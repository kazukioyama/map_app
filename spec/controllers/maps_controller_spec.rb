require 'rails_helper'

RSpec.describe MapsController, type: :controller do

  it "get index" do
    get :index
    expect(response.status).to eq(200)
  end
end
