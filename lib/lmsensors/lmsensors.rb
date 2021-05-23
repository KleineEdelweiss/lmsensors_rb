# lib/lmsensors/lmsensors.rb

require_relative "../lmsensors_base/lmsensors_base"

module LmSensors
  ##
  # Lambda function to determine the enabled
  # state of the sensor subfeature.
  CHK_BEEP = lambda { |v| v < 0.5 ? "disabled" : "enabled" }
  CHK_ENABLE = lambda { |v| v.zero? ? "disabled" : "enabled" }
  
  ##
  # Index of units -- this will map the expected
  # default units to any features. These are taken from
  # the 'lm-sensors' headers, and I have exported the
  # constants from the C-code to here. The names DIRECTLY
  # correspond to the 'sensors_feature_type' enum, but
  # they have been shortened from 'SENSORS_FEATURE_'
  # to 'SF_'.
  # 
  # This is, to the best of my ability, taken from the
  # chips.c file, which has a header you can't seem to
  # access from sensors.h.
  UNITS = {
    SF_IN => "V", # Volts
    SF_FAN => "RPM", # RPM (fan)
    SF_TEMP => "°C", # Degrees Celsius
    SF_POWER => "W", # Watts
    SF_ENERGY => "J", # Energy, Joules [?]
    SF_CURR => "A", # Seems to be current, Amps [?]
    SF_HUMIDITY => "%", # Humidity, percent [?]
    # Skips here
    SF_VID => "V", # Vid -- this is in Volts
    SF_INTRUSION => CHK_ENABLE, # Intrusion
    # Skips here, again
    SF_BEEP_ENABLE => CHK_BEEP, # Beep enabled, true if gte 0.5
  } # End default units enum
  
  ##
  # Wrap the module functions
  # 
  # Contains: 'pro_init', 'pro_cleanup'
  def self.init(filename=nil) self.pro_init(filename) end
  def self.cleanup() self.pro_cleanup end
  
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
    # get -- by default, 'nil', so it
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
    # chip set by 'set_name'.
    def enum(name=@chip_name) pro_enum(nil, name) end
    
    ##
    # Format a subfeature's output
    def self.fmt_sub(value, unit)
      case
      when Proc === unit
        unit.call(value)
      when String === unit
        "#{value} #{unit}"
      else
        value
      end
    end # End subfeature value formatter
    
    ##
    # Stat will return the values and names
    # of all the features associated with the
    # currently-selected chip.
    def stat(cnt=false)
      # If cnt flag is not set, drop the count from the stat
      pro_enum(true, @chip_name).then do |chips|
        cnt ? chips.update({count: chips.count}) : chips end
    end # End stat method
    
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
    def count_s() enum.count end # End count of sensors
    
    ##
    # Return a list of features for all selected
    # chips. This replaces the old version, which
    # only accepted one chip, because it didn't
    # make sense and overcomplicated the process.
    # If only a single chip is desired, you will need
    # to filter it.
    def features(subs = false, filters = [])
      # For each chip, split it by key and value
      stat.collect do |chip_key, data|
        fdata = if Hash === data then
          data[:stat].collect do |feature, keys|
            # Is the filter set?
            no_filter = filters.empty?
            # Is the feature of a type included in the filter?
            included = filters.include?(keys[:type])
            
            # If the filter is NOT set, OR the keys IS included
            # in the filter, proceed.
            if no_filter or included then
              # If the subfeature option is set, return
              # the subfeature data and the unit.
              if subs then
                keys.collect do |sfk, sfv|
                  # Do not include single-item keys
                  if Hash === sfv then
                    # Attach the unit type to the subfeature
                    { sfk => sfv.merge({ unit: LmSensors::UNITS[sfv[:type]] }) }
                  end
                # Remove empties, merge the subfeature hashes together
                end.compact.reduce Hash.new, :merge
              # If the subfeature option is not set, just return
              # the feature type.
              else { feature => keys[:type] } end
            # If filtered and not included, return empty hash
            else {} end
          # Merge the feature hashes together
          end.reduce Hash.new, :merge
        end
        # Create a chip to formatted feature hash
        { chip_key => fdata }
      # Merge them together as a path=>data hash
      end.reduce Hash.new, :merge
    end # End features collector
    
    ##
    # Get the number of features available for
    # the current name (or total features to be
    # read for all sensors).
    def count_f
      total = 0 # Accumulator
      # Add up all the features
      stat.each { |_, v| total += v[:stat].count }
      total # Return accumulator
    end # End count of features
    
    ##
    # Get the number of subfeatures available for
    # the current name (or total features to be
    # read for all sensors).
    def count_sf
      total = 0 # Accumulator
      stat.each do |_, v|
        features = v[:stat].collect do |_k, v|
          # Ignore the :def_units symbol
          total += (v.select { |item| :def_units != item } .count)
        end
      end
      total # Return accumulator
    end # End count of features
  end # End Sensors object class
end # End LmSensors module