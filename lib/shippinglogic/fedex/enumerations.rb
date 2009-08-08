module Shippinglogic
  class FedEx
    # This module contains the various enumerations that FedEx uses for its various options. When describing
    # service options sometimes the docs will specify that the option must be an item in one of these arrays.
    # You can also use these to build drop down options.
    #
    # Lastly, if you want to make these user friendly use a string inflector (humanize or titlize).
    module Enumerations
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
      SIGNATURE_IMAGE_TYPES = ["LETTER", "FAX"]
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
      
      FEDEX_COUNTRY_CODES = {
        "Albania" => "AL",
        "Algeria" => "DZ",
        "American Samoa" => "AS",
        "Andorra" => "AD",
        "Angola" => "AO",
        "Anguilla" => "AI",
        "Antigua" => "AG",
        "Argentina" => "AR",
        "Armenia" => "AM",
        "Aruba" => "AW",
        "Australia" => "AU",
        "Austria" => "AT",
        "Azerbaijan" => "AZ",
        "Bahamas" => "BS",
        "Bahrain" => "BH",
        "Bangladesh" => "BD",
        "Barbados" => "BB",
        "Belarus" => "BY",
        "Belgium " => "BE",
        "Belize" => "BZ",
        "Benin" => "BJ",
        "Bermuda" => "BM",
        "Bhutan" => "BT",
        "Bolivia" => "BO",
        "Botswana " => "BW",
        "Brazil" => "BR",
        "British Virgin Is." => "VG",
        "Brunei" => "BN",
        "Bulgaria" => "BG",
        "Burkino Faso" => "BF",
        "Burma" => "MM",
        "Burundi" => "BI",
        "Cambodia" => "KH",
        "Cameroon" => "CM",
        "Canada" => "CA",
        "Cape Verde" => "CV",
        "Cayman Islands" => "KY",
        "Central African" => "CF",
        "Chad" => "TD",
        "Chile" => "CL",
        "China" => "CN",
        "Colombia" => "CO",
        "Congo" => "CG",
        "Congo, The Republic of" => "CD",
        "Cook Islands" => "CK",
        "Costa Rica" => "CR",
        "Cote D'Ivoire" => "CI",
        "Croatia" => "HR",
        "Cyprus" => "CY",
        "Czech Republic" => "CZ",
        "Denmark" => "DK",
        "Djibouti" => "DJ",
        "Dominica" => "DM",
        "Dominican Republic" => "DO",
        "Ecuador" => "EC",
        "Egypt" => "EG",
        "El Salvador" => "SV",
        "Equatorial Guinea" => "GQ",
        "Eritrea" => "ER",
        "Estonia" => "EE",
        "Ethiopia" => "ET",
        "Faeroe Islands" => "FO",
        "Fiji" => "FJ",
        "Finland" => "FI",
        "France" => "FR",
        "French Guiana" => "GF",
        "French Polynesia" => "PF",
        "Gabon" => "GA",
        "Gambia" => "GM",
        "Georgia, Republic of" => "GE",
        "Germany" => "DE",
        "Ghana" => "GH",
        "Gibraltar" => "GI",
        "Greece" => "GI",
        "Greenland" => "GL",
        "Grenada" => "GD",
        "Guadeloupe" => "GP",
        "Guam" => "GU",
        "Guatemala" => "GT",
        "Guinea" => "GN",
        "Guinea-Bissau" => "GW",
        "Guyana" => "GY",
        "Haiti" => "HT",
        "Honduras" => "HN",
        "Hong Kong" => "HK",
        "Hungary" => "HU",
        "Iceland" => "IS",
        "India" => "IN",
        "Indonesia" => "ID",
        "Ireland" => "IE",
        "Israel" => "IL",
        "Italy" => "IT",
        "Ivory Coast" => "CI",
        "Jamaica" => "JM",
        "Japan" => "JP",
        "Jordan" => "JO",
        "Kazakhstan" => "KZ",
        "Kenya" => "KE",
        "Kuwait" => "KW",
        "Kyrgyzstan" => "KG",
        "Latvia" => "LV",
        "Lebanon" => "LB",
        "Lesotho" => "LS",
        "Liechtenstein" => "LI",
        "Lithuania" => "LT",
        "Luxembourg" => "LU",
        "Macau" => "MO",
        "Macedonia" => "MK",
        "Madagascar" => "MG",
        "Malawi" => "MW",
        "Malaysia" => "MY",
        "Maldives" => "MV",
        "Mali" => "ML",
        "Malta" => "MT",
        "Marshall Islands" => "MH",
        "Martinique" => "MQ",
        "Mauritania" => "MR",
        "Mauritius" => "MU",
        "Mexico" => "MX",
        "Micronesia" => "FM",
        "Moldova" => "MD",
        "Monaco" => "MC",
        "Mongolia" => "MN",
        "Montserrat" => "MS",
        "Morocco" => "MA",
        "Mozambique" => "MZ",
        "Myanmar" => "MM",
        "Namibia" => "NA",
        "Nepal" => "NP",
        "Netherlands" => "NL",
        "Netherlands Antilles" => "AN",
        "New Caledonia" => "NC",
        "New Zealand" => "NZ",
        "Nicaragua" => "NI",
        "Niger" => "NE",
        "Nigeria" => "NG",
        "Norway" => "NO",
        "Oman" => "OM",
        "Pakistan" => "PK",
        "Palau" => "PW",
        "Panama" => "PA",
        "Papau New Guinea" => "PG",
        "Paraguay" => "PY",
        "Peru" => "PE",
        "Phillipines" => "PH",
        "Poland" => "PL",
        "Portugal" => "PT",
        "Puerto Rico" => "US",
        "Quatar" => "QA",
        "Reunion Island" => "RE",
        "Romania" => "RO",
        "Russia" => "RU",
        "Rwanda" => "RW",
        "Saipan" => "MP",
        "San Marino" => "SM",
        "Saudi Arabia" => "SA",
        "Senegal" => "SN",
        "Seychelles" => "SC",
        "Sierra Leonne" => "SL",
        "Singapore" => "SG",
        "Slovak Republic" => "SK",
        "Slovenia" => "SI",
        "South Africa" => "ZA",
        "South Korea" => "KR",
        "Spain" => "ES",
        "Sri Lanka" => "LK",
        "St. Kitts & Nevis" => "KN",
        "St. Lucia" => "LC",
        "St. Vincent" => "VC",
        "Suriname" => "SR",
        "Swaziland" => "SZ",
        "Sweden" => "SE",
        "Switzerland" => "CH",
        "Syria" => "SY",
        "Taiwan" => "TW",
        "Tanzania" => "TZ",
        "Thailand" => "TH",
        "Togo" => "TG",
        "Trinidad & Tobago" => "TT",
        "Tunisia" => "TN",
        "Turkey" => "TR",
        "Turkmenistan, Republic Of" => "TM",
        "Turks & Caicos Is." => "TC",
        "U.A.E." => "AE",
        "U.S. Virgin Islands" => "VI",
        "U.S.A." => "US",
        "Uganda" => "UG",
        "Ukraine" => "UA",
        "United Kingdom" => "GB",
        "Uruguay" => "UY",
        "Uzbekistan" => "UZ",
        "Vanatu" => "VU",
        "Vatican City"=> "VA",
        "Venezuela" => "VE",
        "Vietnam" => "VN",
        "Wallis & Futuna Islands" => "WF",
        "Yemen" => "YE",
        "Zambia" => "ZM",
        "Zimbabwe" => "ZW"
      }
      
      RAILS_COUNTRY_CODES = {
        "United States" => "US"
      }
    end
  end
end