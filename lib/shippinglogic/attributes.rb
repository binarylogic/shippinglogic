module Shippinglogic
  # Adds in all of the reading / writing for the various serivce options.
  module Attributes
    def self.included(klass)
      klass.class_eval do
        alias_method(:real_class, :class) unless method_defined? :real_class
        
        extend ClassMethods
        include InstanceMethods
      end
    end
    
    module ClassMethods
      # Define an attribute for a class, makes adding options / attributes to the class
      # much cleaner. See the Rates class for an example.
      def attribute(name, type, options = {})
        name = name.to_sym
        options[:type] = type.to_sym
        attributes[name] = options
        
        define_method(name) { read_attribute(name) }
        define_method("#{name}=") { |value| write_attribute(name, value) }
      end
      
      # A hash of all the attributes and their options
      def attributes
        @attributes ||= {}
      end
      
      # An array of the attribute names
      def attribute_names
        attributes.keys
      end
      
      # Returns the options specified when defining a specific attribute
      def attribute_options(name)
        attributes[name.to_sym]
      end
    end
    
    module InstanceMethods
      # A convenience so that you can set attributes while initializing an object
      def initialize(*args)
        attributes = args.last.is_a?(Hash) ? args.last : {}
        @attributes = {}
        self.attributes = attributes
      end
      
      # Returns a hash of the various attribute values
      def attributes
        attributes = {}
        attribute_names.each do |name|
          attributes[name] = send(name)
        end
        attributes
      end
      
      # Accepts a hash of attribute values and sets each attribute to those values
      def attributes=(value)
        return if value.blank?
        value.each do |key, value|
          next if !attribute_names.include?(key.to_sym)
          send("#{key}=", value)
        end
      end
      
      private
        def attribute_names
          real_class.attribute_names
        end
        
        def attribute_options(name)
          real_class.attribute_options(name)
        end
        
        def attribute_type(name)
          attribute_options(name)[:type]
        end
        
        def attribute_default(name)
          default = attribute_options(name)[:default]
          case default
          when Proc
            default.call(self)
          else
            default
          end
        end
        
        def write_attribute(name, value)
          @attributes[name.to_sym] = value
        end
        
        def read_attribute(name)
          name = name.to_sym
          value = @attributes[name].nil? ? attribute_default(name) : @attributes[name]
          type = attribute_type(name)
          return nil if value.nil? && type != :array
          
          case type
          when :array
            value.is_a?(Array) ? value : [value].compact
          when :integer
            value.to_i
          when :float
            value.to_f
          when :decimal
            BigDecimal.new(value.to_s)
          when :boolean
            ["true", "1"].include?(value.to_s)
          when :string, :text
            value.to_s
          else
            value
          end
        end
    end
  end
end