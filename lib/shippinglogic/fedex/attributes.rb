module Shippinglogic
  class FedEx
    module Attributes
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
          include InstanceMethods
        end
      end
      
      module ClassMethods
        def attribute(name, type, options = {})
          name = name.to_sym
          options[:type] = type.to_sym
          attributes[name] = options
          
          define_method(name) { read_attribute(name) }
          define_method("#{name}=") { |value| write_attribute(name, value) }
        end
        
        def attributes
          @attributes ||= {}
        end
        
        def attribute_names
          attributes.keys
        end
        
        def attribute_options(name)
          attributes[name.to_sym]
        end
      end
      
      module InstanceMethods
        def initialize(base, attributes = {})
          @attributes = {}
          self.attributes = attributes
        end
        
        def attributes
          attributes = {}
          attribute_names.each do |name|
            attributes[name] = send(name)
          end
          attributes
        end
        
        def attributes=(value)
          return if value.blank?
          value.each do |key, value|
            next if !attribute_names.include?(key.to_sym)
            send("#{key}=", value)
          end
        end
        
        private
          def attribute_names
            self.class.attribute_names
          end
          
          def attribute_options(name)
            self.class.attribute_options(name)
          end
          
          def attribute_type(name)
            attribute_options(name)[:type]
          end
          
          def attribute_default(name)
            default = attribute_options(name)[:default]
            case default
            when Proc
              default.call
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
            when :big_decimal
              BigDecimal.new(value)
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
end