require 'spec_helper'

describe "build_radiator" do
  it "GET '/'" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Its all green here!')
  end
end