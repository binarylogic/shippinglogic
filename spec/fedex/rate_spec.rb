require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "FedEx Rate" do
  it "should rate the shipment" do
    use_response(:rate_defaults)
    
    fedex = new_fedex
    rates = fedex.rate
    
    rates.attributes = fedex_shipper
    rates.attributes = fedex_recipient
    rates.attributes = fedex_package
    rates.size.should == 6
    
    rate = rates.first
    rate.name.should == "First Overnight"
    rate.type.should == "FIRST_OVERNIGHT"
    rate.saturday.should == false
    rate.deadline.should == Time.parse("Fri Aug 07 08:00:00 -0400 2009")
    rate.rate.should == 70.01
    rate.currency.should == "USD"
  end
  
  it "should not require package dimensions when not using custom packaging" do
    use_response(:rate_non_custom_packaging)
    
    fedex = new_fedex
    rates = fedex.rate
    
    rates.attributes = fedex_shipper
    rates.attributes = fedex_recipient
    rates.packaging_type = "FEDEX_ENVELOPE"
    rates.package_weight = 0.1
    
    rates.size.should == 5
    
    rate = rates.first
    rate.name.should == "First Overnight"
    rate.type.should == "FIRST_OVERNIGHT"
    rate.saturday.should == false
    rate.deadline.should == Time.parse("Mon Aug 10 08:00:00 -0400 2009")
    rate.rate.should == 50.43
    rate.currency.should == "USD"
  end
  
  it "should handle responses with no services" do
    use_response(:rate_no_services)
    
    fedex = new_fedex
    rates = fedex.rate
    
    rates.attributes = fedex_shipper
    rates.attributes = fedex_recipient
    rates.packaging_type = "FEDEX_ENVELOPE"
    rates.package_weight = 2
    rates.size.should == 0
  end
  
  it "should remove any services that don't meet the deadline" do
    use_response(:rate_defaults)
    
    fedex = new_fedex
    rates = fedex.rate
    
    rates.attributes = fedex_shipper
    rates.attributes = fedex_recipient
    rates.attributes = fedex_package
    rates.delivery_deadline = Time.parse("Aug 07 08:01:00 -0400 2009")
    rates.size.should == 1
    rates.first.deadline.should == Time.parse("Fri Aug 07 08:00:00 -0400 2009")
  end
end
