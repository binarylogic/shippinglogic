require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Fedex Rate" do
  it "should rate the shipment" do
    use_response(:basic_rate)
    
    fedex = new_fedex
    services = fedex.rate(
      :shipper => fedex_shipper,
      :recipient => fedex_recipient,
      :packages => [fedex_package]
    )
    
    services.size.should == 6
    
    service = services.first
    service[:name].should == "First Overnight"
    service[:service_type].should == "FIRST_OVERNIGHT"
    service[:saturday_delivery].should == false
    service[:delivery_by].should == Time.parse("Thu Aug 06 08:00:00 -0400 2009")
    service[:cost].should == BigDecimal("70.01")
    service[:currency].should == "USD"
  end
end
