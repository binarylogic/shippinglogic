require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Service Validation" do
  before(:all) do
    class ::ServiceWithValidation
      include Shippinglogic::Validation
    end
  end
  
  after(:all) do
    Object.send(:remove_const, :ServiceWithValidation)
  end
  
  it "should provide an empty errors array" do
    service = ServiceWithValidation.new
    service.errors.should == []
  end
  
  context "when calling the valid? method" do
    it "should call the target method" do
      service = ServiceWithValidation.new
      service.should_receive(:target)
      service.valid?
    end
    
    it "should return true if no errors are encountered" do
      service = ServiceWithValidation.new
      service.stub!(:target).and_return(nil)
      service.valid?.should == true
    end
    
    it "should not append any error messages if no errors are encountered" do
      service = ServiceWithValidation.new
      service.stub!(:target).and_return(nil)
      service.valid?
      service.errors.size.should == 0
    end
    
    it "should rescue and append any Shippinglogic::Error messages" do
      service = ServiceWithValidation.new
      error = Shippinglogic::Error.new("", "")
      error.add_error("ERROR")
      service.stub!(:target).and_return{ raise error }
      service.valid?.should_not raise_error(error.class)
      service.errors.size.should == 1
      service.errors.first.should == "ERROR"
    end
  end
end
