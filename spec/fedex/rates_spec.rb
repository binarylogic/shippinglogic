require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "FedEx Rate" do
  it "should rate the shipment" do
    use_response(:basic_rate)
    
    fedex = new_fedex
    rates = fedex.rates
    
    rates.attributes = fedex_shipper
    rates.attributes = fedex_recipient
    rates.packages = [fedex_package]
    rates.size.should == 6
    
    rate = rates.first
    rate.name.should == "First Overnight"
    rate.type.should == "FIRST_OVERNIGHT"
    rate.saturday.should == false
    rate.deadline.should == Time.parse("Fri Aug 07 08:00:00 -0400 2009")
    rate.cost.should == BigDecimal("70.01")
    rate.currency.should == "USD"
  end
end
