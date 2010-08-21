require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FedEx Attributes" do
  it "should convert full country names to country codes" do
    fedex = new_fedex
    rates = fedex.rate
    rates.send(:country_code, "United States").should == "US"
  end
  
  it "should convert full state names to state codes" do
    fedex = new_fedex
    rates = fedex.rate
    rates.send(:state_code, "Texas").should == "TX"
  end
end
