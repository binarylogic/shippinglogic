require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FedEx Ship" do
  before(:each) do
    fedex = new_fedex
    @shipment = fedex.ship
    
    @shipment.service_type = "FEDEX_2_DAY"
    @shipment.attributes = fedex_shipper
    @shipment.attributes = fedex_recipient
    @shipment.attributes = fedex_package
  end
  
  it "should create a new shipment" do
    use_response(:ship_defaults)
    
    @shipment.rate.should == 17.02
    @shipment.currency.should == "USD"
    @shipment.delivery_date.should == Date.parse("Tue, 11 Aug 2009")
    @shipment.tracking_number.should == "794797892957"
    @shipment.label.should_not be_nil
    @shipment.barcode.should_not be_nil
  end
  
  it "should only validate the shipment" do
    # An email from FedEx confirms that this service is only available in production,
    # which makes no sense. So I can not test this, but the implmentation is
    # exactly the same as shipping, and that works just fine. You would think a multi
    # billion dollar company would have decent web services.
  end
end
