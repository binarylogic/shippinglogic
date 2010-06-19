module Shippinglogic
  class UPS
    class ShipConfirm < Service
      def self.path
        "/ShipConfirm"
      end
      
      # shipper options
      attribute :shipper_name,                :string
      attribute :shipper_phone_number,        :string
      attribute :shipper_email,               :string
      attribute :shipper_streets,             :string
      attribute :shipper_city,                :string
      attribute :shipper_state,               :string
      attribute :shipper_postal_code,         :string
      attribute :shipper_country,             :string
      
      # recipient options
      attribute :recipient_name,              :string
      attribute :recipient_phone_number,      :string
      attribute :recipient_email,             :string
      attribute :recipient_streets,           :string
      attribute :recipient_city,              :string
      attribute :recipient_state,             :string
      attribute :recipient_postal_code,       :string
      attribute :recipient_country,           :string
      attribute :recipient_residential,       :boolean,     :default => false
      
      # label options
      attribute :label_format,                :string,      :default => "GIF"
      attribute :label_file_type,             :string,      :default => "GIF"
      
      # packaging options
      attribute :packaging_type,              :string,      :default => "00"
      attribute :package_count,               :integer,     :default => 1
      attribute :package_weight,              :float
      attribute :package_weight_units,        :string,      :default => "LBS"
      attribute :package_length,              :integer
      attribute :package_width,               :integer
      attribute :package_height,              :integer
      attribute :package_dimension_units,     :string,      :default => "IN"
      
      # monetary options
      attribute :currency_type,               :string
      attribute :insured_value,               :decimal
      attribute :payor_account_number,        :string,      :default => lambda { |shipment| shipment.base.number }
      
      # delivery options
      attribute :service_type,                :string
      #FIXME Setting the signature option to true raises and error. I believe this has something
      # to do with UPS account-specific settings and signature service availability.
      attribute :signature,                   :boolean,     :default => false
      attribute :saturday,                    :boolean,     :default => false
      
      # misc options
      #TODO Make use of this option by skipping the ShipAccept API call.
      attribute :just_validate,               :boolean,     :default => false
      
      private
        def target
          @target ||= parse_response(request(build_request))
        end
        
        def build_request
          b = builder
          build_authentication(b)
          b.instruct!
          
          b.ShipmentConfirmRequest do
            b.Request do
              b.RequestAction "ShipConfirm"
              b.RequestOption "validate"
            end
            
            b.Shipment do
              b.Shipper do
                b.Name shipper_name
                b.ShipperNumber payor_account_number
                b.PhoneNumber shipper_phone_number
                b.EMailAddress shipper_email
                build_address(b, :shipper)
              end
              
              b.ShipTo do
                b.CompanyName recipient_name
                b.PhoneNumber recipient_phone_number
                b.EMailAddress recipient_email
                build_address(b, :recipient)
              end
              
              b.PaymentInformation do
                b.Prepaid do
                  b.BillShipper do
                    b.AccountNumber payor_account_number
                  end
                end
              end
              
              b.Service do
                b.Code service_type
              end
              
              b.ShipmentServiceOptions do
                b.SaturdayDelivery if saturday
                if signature
                  b.DeliveryConfirmation do
                    b.DCISType "1"
                  end
                end
              end
              
              package_count.times do |i|
                b.Package do
                  b.PackagingType do
                    b.Code packaging_type
                  end
                  
                  b.Dimensions do
                    b.UnitOfMeasurement do
                      b.Code package_dimension_units
                    end
                    
                    b.Length "%.2f" % package_length
                    b.Width "%.2f" % package_width
                    b.Height "%.2f" % package_height
                  end
                  
                  b.PackageWeight do
                    b.UnitOfMeasurement do
                      b.Code package_weight_units
                    end
                    
                    b.Weight "%.1f" % package_weight
                  end
                  
                  b.PackageServiceOptions do
                    if insured_value
                      b.InsuredValue do
                        b.MonetaryValue insured_value
                        b.CurrencyCode currency_type
                      end
                    end
                  end
                end
              end
            end
            
            b.LabelSpecification do
              b.LabelPrintMethod do
                b.Code label_file_type
              end
              
              b.LabelImageFormat do
                b.Code label_format
              end
            end
          end
        end
        
        def parse_response(response)
          response[:shipment_digest]
        end
    end
  end
end