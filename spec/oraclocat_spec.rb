require 'spec_helper'

describe "Oraclocat" do
  it "accesses the front page" do
    get '/'
    expect(last_response).to be_ok
  end
end
