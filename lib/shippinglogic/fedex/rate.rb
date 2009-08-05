module Shippinglogic
  class Fedex
    # An interface to the rate services provided by Fedex. See the rate method for more info. Alternatively, you can
    # read up on the rate services documentation on the FedEx website. It's a great read.
    module Rate
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
      # * <tt>:special_services_requested</tt> - any exceptions or special services Fedex needs to be aware of, this should be
      #   one or more of SPECIAL_SERVICES. (default: nil)
      # * <tt>:currency_type</tt> - the type of currency. (default: nil, because FedEx will default to your account preferences)
      # * <tt>:rate_request_types</tt> - one or more of RATE_REQUEST_TYPES. (default: ACCOUNT)
      # * <tt>:insured_value</tt> - the value you want to insure, if any. (default: nil)
      # * <tt>:payment_type</tt> - one of PAYMENT_TYPES. (default: SENDER)
      # * <tt>:payor</tt> - this is optional, if the person paying for the shipment is different than the account you specify
      #   then you can specify that information here. This should be a hash with the following elements. (default: nil)
      #   * <tt>:account_number</tt> - the Fedex account number of the company paying for this shipment.
      #   * <tt>:country_code</tt> - the country code for the account number. Ex: 'US'
      #
      # === Simple Example
      #
      # Here is a very simple example. Mix and match the options above to get more accurate rates:
      #
      #   fedex = Shippinglogic::Fedex.new(key, password, account, meter)
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
      def rate(options = {})
        options = rate_defaults.deep_merge(options)
        normalize_rate_options(options)
        xml = build_rate_request(options)
        response = request(xml)
        parse_rate_response(response)
      end
      
      private
        def rate_defaults
          {
            :packages => [],
            :ship_time => Time.now,
            :dropoff_type => "REGULAR_PICKUP",
            :packaging_type => "YOUR_PACKAGING",
            :include_transit_times => true,
            :special_services_requested => [],
            :rate_request_types => ["ACCOUNT"],
            :payment_type => "SENDER"
          }
        end
        
        def normalize_rate_options(options)
          options[:special_services_requested] = [options[:special_services_requested]] if options[:special_services_requested] && !options[:special_services_requested].is_a?(Array)
          options[:rate_request_types] = [options[:rate_request_types]] if options[:rate_request_types] && !options[:rate_request_types].is_a?(Array)
          options[:packages] = [options[:packages]] if options[:packages] && !options[:packages].is_a?(Array)
        end
        
        def package_defaults
          {
            :weight => {:units => "LB"},
            :dimensions => {:units => "IN"}
          }
        end
        
        def build_rate_request(options)
          b = builder
          xml = b.RateRequest(:xmlns => "http://fedex.com/ws/rate/v#{VERSION[:major]}") do
            build_authentication(b)
            build_version(b, "crs", VERSION[:major], VERSION[:intermediate], VERSION[:minor])
            b.ReturnTransitAndCommit options[:include_transit_times]
            b.SpecialServicesRequested options[:special_services_requested].join(",") if !options[:special_services_requested].empty?
            
            b.RequestedShipment do
              b.ShipTimestamp options[:ship_time].xmlschema
              b.ServiceType options[:service_type] if options[:service_type]
              b.DropoffType options[:dropoff_type] if options[:dropoff_type]
              b.PackagingType options[:packaging_type] if options[:packaging_type]
              b.TotalInsuredValue options[:insured_value] if options[:insured_value]
              b.Shipper { build_address(b, options[:shipper]) }
              b.Recipient { build_address(b, options[:recipient]) }
              b.ShippingChargesPayment { b.PaymentType options[:payment_type] }
              b.RateRequestTypes options[:rate_request_types].join(",")
              b.PackageCount options[:packages].size
              b.PackageDetail "INDIVIDUAL_PACKAGES"
              
              options[:packages].each { |package| build_package(b, package) }
            end
          end
        end
        
        def build_address(b, address = {})
          b.Address do
            b.StreetLines address[:street_lines] if address[:street_lines]
            b.City address[:city] if address[:city]
            b.StateOrProvinceCode address[:state_or_province_code] if address[:state_or_province_code]
            b.PostalCode address[:postal_code] if address[:postal_code]
            b.CountryCode address[:country_code] if address[:country_code]
            b.Residential address[:residential] if address[:residential]
          end
        end
        
        def build_package(b, package)
          package = package_defaults.deep_merge(package)
          
          b.RequestedPackages do
            b.Weight do
              b.Units package[:weight][:units]
              b.Value package[:weight][:value]
            end
            
            dimensions = package[:dimensions]
            b.Dimensions do
              b.Length dimensions[:length]
              b.Width dimensions[:width]
              b.Height dimensions[:height]
              b.Units dimensions[:units]
            end
          end
        end
        
        def parse_rate_response(response)
          response[:rate_reply_details].collect do |details|
            shipment_detail = details[:rated_shipment_details].is_a?(Array) ? details[:rated_shipment_details].first : details[:rated_shipment_details]
            cost = shipment_detail[:shipment_rate_detail][:total_net_charge]

            {
              :name => details[:service_type].titleize,
              :service_type => details[:service_type],
              :saturday_delivery => details[:applied_options] == "SATURDAY_DELIVERY",
              :delivery_by => details[:delivery_timestamp] && Time.parse(details[:delivery_timestamp]),
              :cost => BigDecimal.new(cost[:amount]),
              :currency => cost[:currency]
            }
          end
        end
    end
  end
end