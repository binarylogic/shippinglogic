module Shippinglogic
  class UPS
    # This module contains the various enumerations that UPS uses for its various options. When describing
    # service options sometimes the docs will specify that the option must be an item in one of these arrays.
    # You can also use these to build drop down options.
    #
    # Lastly, if you want to make these user friendly use a string inflector (humanize or titlize).
    module Enumerations
      # packaging options
      PACKAGING_TYPES = {
        "00" => "UNKNOWN",
        "01" => "UPS Letter",
        "02" => "Package",
        "03" => "Tube",
        "04" => "Pak",
        "21" => "Express Box",
        "24" => "25KG Box",
        "25" => "10KG Box",
        "30" => "Pallet",
        "2a" => "Small Express Box",
        "2b" => "Medium Express Box",
        "2c" => "Large Express Box"
      }

      # delivery options
      DROPOFF_TYPES = {
        "01" => "Daily Pickup",
        "03" => "Customer Counter",
        "06" => "One Time Pickup",
        "07" => "On Call Air",
        "11" => "Suggested Retail Rates",
        "19" => "Letter Center",
        "20" => "Air Service Center"
      }
      SERVICE_TYPES = {
        "01" => "Next Day Air",
        "02" => "2nd Day Air",
        "03" => "Ground",
        "07" => "Worldwide Express",
        "08" => "Worldwide Expedited",
        "11" => "Standard",
        "12" => "3 Day Select",
        "13" => "Next Day Air Saver",
        "14" => "Next Day Air Early AM",
        "54" => "Worldwide Express Plus",
        "59" => "2nd Day Air AM",
        "65" => "Saver",
        "82" => "UPS Today Standard",
        "83" => "UPS Today Dedicated Courier",
        "84" => "UPS Today Intercity",
        "85" => "UPS Today Express",
        "86" => "UPS Today Express Saver"
      }
    end
  end
end