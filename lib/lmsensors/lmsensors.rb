# lib/lmsensors/lmsensors.rb

require_relative "../lmsensors_base/lmsensors_base"

module LmSensors
  ##
  # Reference copy of enumerator from the
  # actual library (valid as of at least 2021-May-19)
  <<~ENUM
  SENSORS_FEATURE_IN		= 0x00,
  SENSORS_FEATURE_FAN		= 0x01,
  SENSORS_FEATURE_TEMP		= 0x02,
  SENSORS_FEATURE_POWER		= 0x03,
  SENSORS_FEATURE_ENERGY		= 0x04,
  SENSORS_FEATURE_CURR		= 0x05,
  SENSORS_FEATURE_HUMIDITY	= 0x06,
  SENSORS_FEATURE_MAX_MAIN,
  SENSORS_FEATURE_VID		= 0x10,
  SENSORS_FEATURE_INTRUSION	= 0x11,
  SENSORS_FEATURE_MAX_OTHER,
  SENSORS_FEATURE_BEEP_ENABLE	= 0x18,
  SENSORS_FEATURE_MAX,
  SENSORS_FEATURE_UNKNOWN		= INT_MAX,
  ENUM
  # End enumerator copy
  
  ##
  # Lambda function to determine the enabled
  # state of the sensor subfeature.
  CHK_ENABLE = lambda { |v| v.zero? ? "disabled" : "enabled" }
  
  ##
  # Index of units -- this will map the expected
  # default units to any features. These are taken from
  # the above reference copy, because there is no
  # direct way to map these -- the library uses an
  # enum and then has functions that are not accessible from
  # the dev headers, and the formatting is not correct for
  # the generic purpose of this library.
  # 
  # This is, to the best of my ability, taken from the
  # chips.c file, which has a header you can't seem to
  # access from sensors.h.
  DEF_UNITS = {
    0x00 => "V", # Volts
    0x01 => "RPM", # RPM (fan)
    0x02 => "°C", # Degrees Celsius
    0x03 => "W", # Watts
    0x04 => "J", # Energy, Joules [?]
    0x05 => "A", # Seems to be current, Amps [?]
    0x06 => "%", # Humidity, percent [?]
    # Skips here
    0x10 => "V", # Vid -- ????? Volts????
    0x11 => CHK_ENABLE, # Intrusion
    # Skips here, again
    0x18 => CHK_ENABLE, # Beep enabled, true if greater than 0
  } # End default units enum
  
  ##
  # Wrap the module functions
  # 
  # Contains: ``pro_init``, ``pro_cleanup``
  def self.init(filename=nil) self.pro_init(filename) end
  def self.cleanup() self.pro_cleanup end
    
  ##
  # Format a selected subfeature's value.
  # 
  # 'sf' is the subfeature item.
  # 'fu_idx' is the feature unit index
  def self.fmt_sub(sf, fu_idx)
    du = LmSensors::DEF_UNITS[fu_idx]
    (Proc === du) ? du.call(sf[:value]) : "#{sf[:value]} #{du}".strip
  end # end formatting of subfeature
  
  ##
  # Sensors inherits the SensorsBase class
  # from the C side of the code. This abstracts
  # several features that were better-suited for
  # processing in a high-level language.
  class Sensors < LmSensors::SensorsBase
    attr_reader :chip_name
    
    ##
    # Constructor
    def initialize() pro_initialize end
      
    ##
    # Set the chip's name you want to
    # get -- by default, ``nil``, so it
    # will return ALL the chips
    def set_name(name) @chip_name = name end
        
    ##
    # Unset the current chip's name, so
    # it returns ALL the chips, again
    def unset_name() @chip_name = nil end
          
    ##
    # Return the currently-monitored chip's name
    def get_name() @chip_name end
            
    ##
    # Enumerate the chip and its features.
    # 
    # This will return a hash of either ALL
    # the available chips or the selected
    # chip set by ``set_name``.
    def enum(name=@chip_name) pro_enum(nil, @chip_name) end
              
    ##
    # Stat will return the values and names
    # of all the features associated with the
    # currently-selected chip.
    def stat() pro_enum(true, @chip_name) end
  end
end