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
    
    ##
    # Find a device sensors by its path, in such
    # a case where the app already has a device from
    # sysfs or similar and needs to attach them together.
    # 
    # Sets the name of the sensor, as well, so this should
    # be used as an instance.
    def locate(path)
      # Clean the path input
      path = path.strip.gsub(/\/*$/, "")
      
      # Check if path is a directory, else exit early.
      # Do not need to check File.exist? first, b/c this
      # already returns nil, if it doesn't.
      if !File.directory?(path) then
        STDERR.puts "::Sensors ERROR:: Path is either invalid or not a directory!"
        return nil
      end # End directory check
      
      # Determine if it's a valid sensor, since the
      # sensors here use the path as the index.
      # If so, set it as this object's name
      enum.then do |sensors|
        # Return early, if it's not in the keys
        if !sensors.keys.include?(path) then
          STDERR.puts "Path does not have an associated sensor"
          return nil
        end # End check for valid sensor path
        
        # Set the name and return it
        set_name sensors[path][:name]
        get_name
      end # End enumeration handler
    end # End locate by path
    
    ##
    # Get the number of sensors available
    # for the current name (or the total number
    # of sensors available).
    def count_s() enum[:total_sensors] end # End count of sensors
    
    ##
    # Get the number of features available for
    # the current name (or total features to be
    # read for all sensors).
    def count_f
      total = 0 # Accumulator
      # Add up all the features
      only_sensors.each { |_, v| total += v[:stat].count }
      total # Return accumulator
    end # End count of features
    
    ##
    # Get the number of subfeatures available for
    # the current name (or total features to be
    # read for all sensors).
    def count_sf
      total = 0 # Accumulator
      only_sensors.each do |_, v|
        features = v[:stat].collect do |_k, v|
          # Ignore the :def_units symbol
          total += (v.select { |item| :def_units != item } .count)
        end
      end
      total # Return accumulator
    end # End count of features
    
    ##
    # Get only the features, not the counter.
    def only_sensors
      # Reject the symbol, b/c it will be :total_sensors.
      # All others are string paths as key.
      stat.reject { |item| Symbol === item }
    end # end getting only the sensors
  end # End Sensors object class
end # End LmSensors module