require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "FedEx Attributes" do
  it "should convert full country names to country codes" do
    fedex = new_fedex
    rates = fedex.rate
    rates.send(:country_code, "United States of America").should == "US"
  end
end
