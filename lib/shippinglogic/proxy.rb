module Shippinglogic
  class Proxy
    alias_method :real_class, :class
    instance_methods.each do |m|
      if (m =~ /^(__|respond_to_missing\?|real_class$|send$|object_id|respond_to\?$)/).nil?
        undef_method(m)
      end
    end
    
    attr_accessor :target
    
    def initialize(target)
      self.target = target
    end
    
    protected
      # We undefined a lot of methods at the beginning of this class. The only methods present in this
      # class are ones that we need, everything else is delegated to our target object.
      def method_missing(name, *args, &block)
        target.send(name, *args, &block)
      end
  end
end