require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Shippinglogic Errors" do
  before(:each) do
    @error = Shippinglogic::Error.new
  end
  
  it "should inherit from StandardError" do
    @error.should be_a(StandardError)
  end
  
  it "should contain an array of errors" do
    @error.errors.should == []
  end
  
  it "should be able to add error hashes" do
    @error.errors.size.should == 0
    @error.add_error("MESSAGE")
    @error.errors.size.should == 1
    @error.errors.last.should be_a(Hash)
  end
  
  it "should append (not prepend) error hashes" do
    @error.add_error("FIRST")
    @error.errors.last[:message].should == "FIRST"
    @error.add_error("LAST")
    @error.errors.last[:message].should == "LAST"
  end
  
  it "should have error hashes containing a required message" do
    @error.add_error("MESSAGE")
    @error.errors.last.should have_key(:message)
    @error.errors.last[:message].should == "MESSAGE"
  end
  
  it "should have error hashes containing an optional code" do
    @error.add_error("WITHOUT")
    @error.errors.last.should have_key(:code)
    @error.errors.last[:code].should be_nil
    @error.add_error("WITH", "CODE")
    @error.errors.last[:code].should == "CODE"
  end
end