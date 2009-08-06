module Shippinglogic
  class FedEx
    # An interface to the rate services provided by FedEx.
    class Rates < Service
      class Rate; attr_accessor :name, :type, :saturday, :deadline, :cost, :currency; end
      
      include HTTParty
      include Request
      include Response
      
      VERSION = {:major => 6, :intermediate => 0, :minor => 0}
      DROP_OFF_TYPES = ["REGULAR_PICKUP", "REQUEST_COURIER", "DROP_BOX", "BUSINESS_SERVICE_CENTER", "STATION"]
      PACKAGE_TYPES = ["FEDEX_ENVELOPE", "FEDEX_PAK", "FEDEX_BOX", "FEDEX_TUBE", "FEDEX_10KG_BOX", "FEDEX_25KG_BOX", "YOUR_PACKAGING"]
      SPECIAL_SERVICES = [
        "APPOINTMENT_DELIVERY", "DANGEROUS_GOODS", "DRY_ICE", "NON_STANDARD_CONTAINER", "PRIORITY_ALERT", "SIGNATURE_OPTION",
        "FEDEX_FREIGHT", "FEDEX_NATIONAL_FREIGHT", "INSIDE_PICKUP", "INSIDE_DELIVERY", "EXHIBITION", "EXTREME_LENGTH", "FLATBED_TRAILER",
        "FREIGHT_GUARANTEE", "LIFTGATE_DELIVERY", "LIFTGATE_PICKUP", "LIMITED_ACCESS_DELIVERY", "LIMITED_ACCESS_PICKUP", "PRE_DELIVERY_NOTIFICATION",
        "PROTECTION_FROM_FREEZING", "REGIONAL_MALL_DELIVERY", "REGIONAL_MALL_PICKUP"
      ]
      RATE_REQUEST_TYPES = ["ACCOUNT", "LIST", "MULTIWEIGHT"]
      PAYMENT_TYPES = ["SENDER", "CASH", "CREDIT_CARD"]
      SERVICE_TYPES = [
        "INTERNATIONAL_FIRST", "FEDEX_3_DAY_FREIGHT", "STANDARD_OVERNIGHT", "PRIORITY_OVERNIGHT", "FEDEX_GROUND", "INTERNATIONAL_PRIORITY",
        "FIRST_OVERNIGHT", "FEDEX_1_DAY_FREIGHT", "FEDEX_2_DAY_FREIGHT", "INTERNATIONAL_GROUND", "INTERNATIONAL_ECONOMY_FREIGHT", "INTERNATIONAL_ECONOMY",
        "FEDEX_1_DAY_FREIGHT_SATURDAY_DELIVERY", "INTERNATIONAL_PRIORITY_FREIGHT", "FEDEX_2_DAY_FREIGHT_SATURDAY_DELIVERY", "FEDEX_2_DAY_SATURDAY_DELIVERY",
        "FEDEX_3_DAY_FREIGHT_SATURDAY_DELIVERY", "FEDEX_2_DAY", "PRIORITY_OVERNIGHT_SATURDAY_DELIVERY", "INTERNATIONAL_PRIORITY_SATURDAY_DELIVERY",
        "FEDEX_EXPRESS_SAVER", "GROUND_HOME_DELIVERY"
      ]
      
      attribute :shipper_streets,             :string
      attribute :shipper_city,                :string
      attribute :shipper_state,               :string
      attribute :shipper_zip,                 :string
      attribute :shipper_country,             :string
      attribute :shipper_residential,         :boolean,     :default => false
      
      attribute :recipient_streets,           :string
      attribute :recipient_city,              :string
      attribute :recipient_state,             :string
      attribute :recipient_zip,               :string
      attribute :recipient_country,           :string
      attribute :recipient_residential,       :boolean,     :default => false
      
      attribute :service_type,                :string
      attribute :packaging_type,              :string,      :default => "YOUR_PACKAGING"
      attribute :packages,                    :array
      attribute :ship_time,                   :datetime,    :default => lambda { Time.now }
      attribute :dropoff_type,                :boolean,     :default => "REGULAR_PICKUP"
      attribute :include_transit_times,       :boolean,     :default => true
      attribute :delivery_deadline,           :datetime
      attribute :special_services_requested,  :array
      attribute :currency_type,               :string
      attribute :rate_request_types,          :array,       :default => ["ACCOUNT"]
      attribute :insured_value,               :big_decimal
      attribute :payment_type,                :string,      :default => "SENDER"
      attribute :payor_account_number,        :string
      attribute :payor_country_code,          :string
      
      private
        # This method can return all of the available services with their rates, transit times, etc. It can also
        # return information on a specific fedex service.
        #
        # === Options
        #
        # * <tt>:shipper</tt> - a hash of address information.
        #   * <tt>:street_lines</tt> - street part of the address, separate multiple streets with a new line, dont include blank lines.
        #   * <tt>:city</tt> - city part of the address.
        #   * <tt>:state_or_province_code</tt> - state part of the address, use state abreviations.
        #   * <tt>:postal_code</tt> - post code part of the address, zip for the US.
        #   * <tt>:country_code</tt> - country code part of the address, use abbreviations, ex: 'US'
        #   * <tt>:residential</tt> - a boolean value representing if the address is redential or not (default: nil)
        # * <tt>:recipient</tt> - a hash of address information.
        #   * <tt>:street_lines</tt> - street part of the address, separate multiple streets with a new line, dont include blank lines.
        #   * <tt>:city</tt> - city part of the address.
        #   * <tt>:state_or_province_code</tt> - state part of the address, use state abreviations.
        #   * <tt>:postal_code</tt> - post code part of the address, zip for the US.
        #   * <tt>:country_code</tt> - country code part of the address, use abbreviations, ex: 'US'
        #   * <tt>:residential</tt> - a boolean value representing if the address is redential or not (default: nil)
        # * <tt>:service_type</tt> - one of SERVICE_TYPES, this is optional, leave this blank if you want a list of all
        #   available services. (default: nil)
        # * <tt>:packaging_type</tt> - one of PACKAGE_TYPES. (default: YOUR_PACKAGING)
        # * <tt>:packages</tt> - an array of packages included in the shipment. This is optional and should default to whatever your packing
        #   type default is in your FedEx account. I am also fairly confident this is only required when using YOUR_PACKAGING as your
        #   packaging type. This should be an array of hashes with the following structure:
        #   * <tt>:weight</tt> - a hash of details about a single package weight
        #     * <tt>:units</tt> - either LB or KG. (default: LB)
        #     * <tt>:value</tt> - the weight
        #   * <tt>:dimensions</tt> - a hash of details about a single package dimensions
        #     * <tt>:units</tt> - either IN or CM. (default: IN)
        #     * <tt>:length</tt> - the length
        #     * <tt>:width</tt> - the width
        #     * <tt>:height</tt> - the height
        # * <tt>:ship_time</tt> - a Time object representing when you want to ship the package. (default: Time.now)
        # * <tt>:dropoff_type</tt> - one of DROP_OFF_TYPES. (default: REGULAR_PICKUP)
        # * <tt>:include_transit_times</tt> - whether or not to include estimated transit times. (default: true)
        # * <tt>:delivery_deadline</tt> - whether or not to include estimated transit times. (default: true)
        # * <tt>:special_services_requested</tt> - any exceptions or special services FedEx needs to be aware of, this should be
        #   one or more of SPECIAL_SERVICES. (default: nil)
        # * <tt>:currency_type</tt> - the type of currency. (default: nil, because FedEx will default to your account preferences)
        # * <tt>:rate_request_types</tt> - one or more of RATE_REQUEST_TYPES. (default: ACCOUNT)
        # * <tt>:insured_value</tt> - the value you want to insure, if any. (default: nil)
        # * <tt>:payment_type</tt> - one of PAYMENT_TYPES. (default: SENDER)
        # * <tt>:payor</tt> - this is optional, if the person paying for the shipment is different than the account you specify
        #   then you can specify that information here. This should be a hash with the following elements. (default: nil)
        #   * <tt>:account_number</tt> - the FedEx account number of the company paying for this shipment.
        #   * <tt>:country_code</tt> - the country code for the account number. Ex: 'US'
        #
        # === Simple Example
        #
        # Here is a very simple example. Mix and match the options above to get more accurate rates:
        #
        #   fedex = Shippinglogic::FedEx.new(key, password, account, meter)
        #   fedex.available_services(
        #     :shipper => {
        #       :postal_code => "10007",
        #       :country_code => "US"
        #     },
        #     :recipient => {
        #       :postal_code => "75201",
        #       :country_code => "US"
        #     },
        #     :packages => [
        #       {
        #         :weight => {:value => 24},
        #         :dimensions => {:length => 12, :width => 12, :height => 12}
        #       }
        #     ]
        #   )
        def target
          @target ||= parse_rate_response(request(build_rate_request))
        end
        
        def build_rate_request
          b = builder
          xml = b.RateRequest(:xmlns => "http://fedex.com/ws/rate/v#{VERSION[:major]}") do
            build_authentication(b)
            build_version(b, "crs", VERSION[:major], VERSION[:intermediate], VERSION[:minor])
            b.ReturnTransitAndCommit include_transit_times
            b.SpecialServicesRequested special_services_requested.join(",") if special_services_requested.any?
            
            b.RequestedShipment do
              b.ShipTimestamp ship_time.xmlschema
              b.ServiceType service_type if service_type
              b.DropoffType dropoff_type if dropoff_type
              b.PackagingType packaging_type if packaging_type
              b.TotalInsuredValue insured_value if insured_value
              b.Shipper { build_address(b, :shipper) }
              b.Recipient { build_address(b, :recipient) }
              b.ShippingChargesPayment { b.PaymentType payment_type }
              b.RateRequestTypes rate_request_types.join(",")
              b.PackageCount packages.size
              b.PackageDetail "INDIVIDUAL_PACKAGES"
              
              packages.each { |package| build_package(b, package) }
            end
          end
        end
        
        def build_address(b, type)
          b.Address do
            b.StreetLines send("#{type}_streets") if send("#{type}_streets")
            b.City send("#{type}_city") if send("#{type}_city")
            b.StateOrProvinceCode send("#{type}_state") if send("#{type}_state")
            b.PostalCode send("#{type}_zip") if send("#{type}_zip")
            b.CountryCode send("#{type}_country") if send("#{type}_country")
            b.Residential send("#{type}_residential")
          end
        end
        
        def build_package(b, package)
          package.symbolize_keys! if package.respond_to?(:symbolize_keys!)
          validate_package(package)
          
          b.RequestedPackages do
            b.Weight do
              b.Units package[:weight_units] || "LB"
              b.Value package[:weight]
            end
            
            b.Dimensions do
              b.Length package[:length]
              b.Width package[:width]
              b.Height package[:height]
              b.Units package[:dimension_units] || "IN"
            end
          end
        end
        
        def validate_package(package)
          raise ArgumentError.new("Each package much be in a Hash format") if !package.is_a?(Hash)
          package.assert_valid_keys(:weight, :weight_units, :length, :height, :width, :dimension_units)
        end
        
        def parse_rate_response(response)
          response[:rate_reply_details].collect do |details|
            shipment_detail = details[:rated_shipment_details].is_a?(Array) ? details[:rated_shipment_details].first : details[:rated_shipment_details]
            cost = shipment_detail[:shipment_rate_detail][:total_net_charge]
            
            rate = Rate.new
            rate.name = details[:service_type].titleize
            rate.type = details[:service_type]
            rate.saturday = details[:applied_options] == "SATURDAY_DELIVERY"
            rate.deadline = details[:delivery_timestamp] && Time.parse(details[:delivery_timestamp])
            rate.cost = BigDecimal.new(cost[:amount])
            rate.currency = cost[:currency]
            rate
          end
        end
    end
  end
end