module Shippinglogic
  class Proxy
    alias_method :real_class, :class
    instance_methods.each { |m| undef_method m unless m =~ /^(__|real_class$)/ }
    
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