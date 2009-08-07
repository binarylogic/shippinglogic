require "shippinglogic/fedex/attributes"
require "shippinglogic/fedex/request"
require "shippinglogic/fedex/response"
require "shippinglogic/fedex/validation"

module Shippinglogic
  class FedEx
    class Service
      alias_method :real_class, :class
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^real_class$|^send$|^object_id$)/ }
      
      include Attributes
      include HTTParty
      include Request
      include Response
      include Validation
      
      # These constants aren't referenced or used anywhere in this library, they are purely for reference and as a tool for your to use.
      # Many of the options that these services accept require a value from one of these arrays. The docs will specify which
      # constant to use. You also might want to include these in a drop down on your interface.
      #
      # Lastly, if you want to make these user friendly use a string inflector (humanize or titlize).
      
      # label options
      LABEL_FORMATS = ["COMMON2D", "ERROR", "LABEL_DATA_ONLY", "MAILROOM", "NO_LABEL"]
      LABEL_FILE_TYPES = ["DIB", "DPL", "EPL2", "GIF", "PDF", "PNG", "ZPLII"]
      LABEL_STOCK_TYPES = [
        "PAPER_4X6", "PAPER_4X8", "PAPER_4X9", "PAPER_7X4.75", "PAPER_8.5X11_BOTTOM_HALF_LABEL", "PAPER_8.5X11_TOP_HALF_LABEL",
        "PAPER_LETTER", "STOCK_4X6", "STOCK_4X6.75_LEADING_DOC_TAB", "STOCK_4X6.75_TRAILING_DOC_TAB", "STOCK_4X8",
        "STOCK_4X9_LEADING_DOC_TAB", "STOCK_4X9_TRAILING_DOC_TAB"
      ]
      LABEL_MASK_OPTIONS = [
        "CUSTOMS_VALUE", "DIMENSIONS", "DUTIES_AND_TAXES_PAYOR_ACCOUNT_NUMBER", "FREIGHT_PAYOR_ACCOUNT_NUMBER",
        "PACKAGE_SEQUENCE_AND_COUNT", "SHIPPER_ACCOUNT_NUMBER", "SUPPLEMENTAL_LABEL_DOC_TAB", "TERMS_AND_CONDITIONS",
        "TOTAL_WEIGHT", "TRANSPORTATION_CHARGES_PAYOR_ACCOUNT_NUMBER"
      ]
      
      # service options
      REGULAR_SERVICE_TYPES = [
        "GROUND_HOME_DELIVERY", "FEDEX_GROUND", "FEDEX_EXPRESS_SAVER", "FEDEX_2_DAY", "STANDARD_OVERNIGHT",
        "PRIORITY_OVERNIGHT", "FIRST_OVERNIGHT"
      ]
      REGULAR_SATURDAY_SERVICE_TYPES = ["FEDEX_2_DAY_SATURDAY_DELIVERY", "PRIORITY_OVERNIGHT_SATURDAY_DELIVERY"]
      FREIGHT_SERVICE_TYPES = ["FEDEX_3_DAY_FREIGHT", "FEDEX_2_DAY_FREIGHT", "FEDEX_1_DAY_FREIGHT"]
      FREIGHT_SATURDAY_SERVICE_TYPES = [
        "FEDEX_3_DAY_FREIGHT_SATURDAY_DELIVERY", "FEDEX_2_DAY_FREIGHT_SATURDAY_DELIVERY",
        "FEDEX_1_DAY_FREIGHT_SATURDAY_DELIVERY"
      ]
      INTERNATIONAL_SERVICE_TYPES = ["INTERNATIONAL_GROUND", "INTERNATIONAL_ECONOMY", "INTERNATIONAL_PRIORITY", "INTERNATIONAL_FIRST"]
      INTERNATIONAL_SATURDAY_TYPES = ["INTERNATIONAL_PRIORITY_SATURDAY_DELIVERY"]
      INTERNATIONA_FREIGHT_SERVICE_TYPES = ["INTERNATIONAL_ECONOMY_FREIGHT", "INTERNATIONAL_PRIORITY_FREIGHT"]
      SERVICE_TYPES = REGULAR_SERVICE_TYPES + REGULAR_SATURDAY_SERVICE_TYPES + FREIGHT_SERVICE_TYPES + FREIGHT_SATURDAY_SERVICE_TYPES +
        INTERNATIONAL_SERVICE_TYPES + INTERNATIONAL_SATURDAY_TYPES + INTERNATIONA_FREIGHT_SERVICE_TYPES
      
      # delivery options
      SIGNATURE_OPTION_TYPES = ["ADULT", "DIRECT", "INDIRECT", "NO_SIGNATURE_REQUIRED", "SERVICE_DEFAULT"]
      SPECIAL_SERVICES = [
        "APPOINTMENT_DELIVERY", "DANGEROUS_GOODS", "DRY_ICE", "NON_STANDARD_CONTAINER", "PRIORITY_ALERT", "SIGNATURE_OPTION",
        "FEDEX_FREIGHT", "FEDEX_NATIONAL_FREIGHT", "INSIDE_PICKUP", "INSIDE_DELIVERY", "EXHIBITION", "EXTREME_LENGTH", "FLATBED_TRAILER",
        "FREIGHT_GUARANTEE", "LIFTGATE_DELIVERY", "LIFTGATE_PICKUP", "LIMITED_ACCESS_DELIVERY", "LIMITED_ACCESS_PICKUP", "PRE_DELIVERY_NOTIFICATION",
        "PROTECTION_FROM_FREEZING", "REGIONAL_MALL_DELIVERY", "REGIONAL_MALL_PICKUP"
      ]
      
      # misc options
      DELETION_CONTROL = ["DELETE_ALL_PACKAGES", "DELETE_ONE_PACKAGE", "LEGACY"]
      EMAIL_TYPES = ["HTML", "TEXT", "WIRELESS"]
      PAYMENT_TYPES = ["SENDER", "CASH", "CREDIT_CARD"]
      REFERENCE_TYPES = [
        "BILL_OF_LADING", "CUSTOMER_REFERENCE", "DEPARTMENT_NUMBER", "INVOICE_NUMER", "P_O_NUMBER",
        "SHIPMENT_INTEGRITY", "STORE_NUMBER"
      ]
      PACKAGE_TYPES = ["FEDEX_ENVELOPE", "FEDEX_PAK", "FEDEX_BOX", "FEDEX_TUBE", "FEDEX_10KG_BOX", "FEDEX_25KG_BOX", "YOUR_PACKAGING"]
      DROP_OFF_TYPES = ["REGULAR_PICKUP", "REQUEST_COURIER", "DROP_BOX", "BUSINESS_SERVICE_CENTER", "STATION"]
      RATE_REQUEST_TYPES = ["ACCOUNT", "LIST", "MULTIWEIGHT"]
      
      attr_accessor :base
      
      # Accepts the base service object as a single parameter so that we can access
      # authentication credentials and options.
      def initialize(base, attributes = {})
        self.base = base
        super
      end
      
      private
        # We undefined a lot of methods at the beginning of this class. The only methods present in this
        # class are ones that we need, everything else is delegated to our target object.
        def method_missing(name, *args, &block)
          target.send(name, *args, &block)
        end
        
        # For each service you need to overwrite this method. This is where you make the call to fedex
        # and do your magic. See the child classes for examples on how to define this method. It is very
        # important that you cache the result into a variable to avoid uneccessary requests.
        def target
          raise ImplementationError.new("You need to implement a target method that the proxy class can delegate method calls to")
        end
    end
  end
end