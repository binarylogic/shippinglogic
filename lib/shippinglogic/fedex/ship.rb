module Shippinglogic
  class FedEx
    class Ship < Service
      class Shipment; attr_accessor :rate, :currency, :delivery_date, :tracking_number, :label, :barcode; end
      
      VERSION = {:major => 6, :intermediate => 0, :minor => 0}
      
      # shipper options
      attribute :shipper_name,                :string
      attribute :shipper_company_name,        :string
      attribute :shipper_phone_number,        :string
      attribute :shipper_streets,             :string
      attribute :shipper_city,                :string
      attribute :shipper_state,               :string
      attribute :shipper_postal_code,         :string
      attribute :shipper_country,             :string
      attribute :shipper_residential,         :boolean,     :default => false
      
      # recipient options
      attribute :recipient_name,              :string
      attribute :recipient_company_name,      :string
      attribute :recipient_phone_number,      :string
      attribute :recipient_streets,           :string
      attribute :recipient_city,              :string
      attribute :recipient_state,             :string
      attribute :recipient_postal_code,       :string
      attribute :recipient_country,           :string
      attribute :recipient_residential,       :boolean,     :default => false
      
      # label options
      attribute :label_format,                :string,      :default => "COMMON2D"
      attribute :label_file_type,             :string,      :default => "PDF"
      attribute :label_stock_type,            :string,      :default => "PAPER_8.5X11_TOP_HALF_LABEL"
      
      # packaging options
      attribute :packaging_type,              :string,      :default => "YOUR_PACKAGING"
      attribute :packages,                    :array
      attribute :dropoff_type,                :string,      :default => "REGULAR_PICKUP"
      
      # monetary options
      attribute :currency_type,               :string
      attribute :insured_value,               :big_decimal
      attribute :payment_type,                :string,      :default => "SENDER"
      attribute :payor_account_number,        :string,      :default => lambda { |shipment| shipment.base.account }
      attribute :payor_country,               :string
      
      # misc options
      attribute :service_type,                :string
      attribute :ship_time,                   :datetime,    :default => lambda { |shipment| Time.now }
      attribute :special_services_requested,  :array
      attribute :rate_request_types,          :array,       :default => ["ACCOUNT"]
      
      private
        def target
          @target ||= parse_response(request(build_request))
        end
        
        def build_request
          b = builder
          xml = b.ProcessShipmentRequest(:xmlns => "http://fedex.com/ws/ship/v#{VERSION[:major]}") do
            build_authentication(b)
            build_version(b, "ship", VERSION[:major], VERSION[:intermediate], VERSION[:minor])
            b.SpecialServicesRequested special_services_requested.join(",") if special_services_requested.any?
            
            b.RequestedShipment do
              b.ShipTimestamp ship_time.xmlschema if ship_time
              b.DropoffType dropoff_type if dropoff_type
              b.ServiceType service_type if service_type
              b.PackagingType packaging_type if packaging_type
              b.TotalInsuredValue insured_value if insured_value
              
              b.Shipper do
                build_contact(b, :shipper)
                build_address(b, :shipper)
              end
              
              b.Recipient do
                build_contact(b, :recipient)
                build_address(b, :recipient)
              end
              
              b.ShippingChargesPayment do
                b.PaymentType payment_type if payment_type
                b.Payor do
                  b.AccountNumber payor_account_number if payor_account_number
                  b.CountryCode payor_country if payor_country
                end
              end
              
              b.LabelSpecification do
                b.LabelFormatType label_format if label_format
                b.ImageType label_file_type if label_file_type
                b.LabelStockType label_stock_type if label_stock_type
              end
              
              b.RateRequestTypes rate_request_types.join(",")
              b.PackageCount packages.size
              
              packages.each_with_index { |package, index| build_package(b, package, index + 1) }
            end
          end
        end
        
        def parse_response(response)
          details = response[:completed_shipment_detail]
          rate = details[:shipment_rating][:shipment_rate_details].first[:total_net_charge]
          package_details = details[:completed_package_details]
          
          shipment = Shipment.new
          shipment.rate = BigDecimal.new(rate[:amount])
          shipment.currency = rate[:currency]
          shipment.delivery_date = Date.parse(details[:routing_detail][:delivery_date])
          shipment.tracking_number = package_details[:tracking_id][:tracking_number]
          shipment.label = Base64.decode64(package_details[:label][:parts][:image])
          shipment.barcode = Base64.decode64(package_details[:barcodes][:common2_d_barcode])
          shipment
        end
    end
  end
end