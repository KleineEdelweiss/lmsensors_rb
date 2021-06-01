# lib/lmsensors/sensors/sensors.rb

# Require the abstract sensor
require_relative "./abssensor"

# :nodoc: This module will house the concrete implementation
# :nodoc: of the actual Sensor object types.
module LmSensors
  ##
  # Sensor is a concrete implementation
  # of the AbsSensor. This implementation
  # is a specific object dedicated to an
  # individual sensor chip.
  class Sensor < LmSensors::AbsSensor
    ##
    # Sensor :path is the '/sys/class/hwmon/' path for this specific sensor
    attr_reader :path
    # Sensor :adapter is the adapter type, like the PCI or ISA adapter
    attr_reader :adapter
    
    ##
    # Find a device sensors by its path, in such
    # a case where the app already has a device from
    # sysfs or similar and needs to attach them together.
    # 
    # Sets the name of the sensor, as well, so this should
    # be used as an instance.
    def locate(path)
      # Validate the path
      dir = path_valid?(path)
      if !dir then return nil end
      # Determine if it's a valid sensor, since the
      # sensors here use the path as the index.
      # If so, set it as this object's name
      raw = pro_enum(nil, nil)
      # Check if the enum value is valid
      if (![Hash, Array].include?(raw.class)) then
        STDERR.puts raw
        return nil
      end # End enum check
      raw.then do |sensors|
        # Return early, if it's not in the keys
        if !sensors.keys.include?(dir) then
          STDERR.puts "Path does not have an associated sensor"
          return nil
        end # End check for valid sensor path
        
        # Set the data and return the chip name
        data = sensors[dir]
        @chip_name = data[:name]
        @adapter = data[:adapter]
        @path = data[:path]
        @chip_name
      end # End enumeration handler
    end # End locate by path
    
    ##
    # Return the core chip data. This does NOT include
    # the features and subfeatures, just the information
    # on the chip itself.
    def info() { name: name, adapter: @adapter, path: @path, } end
    
    ##
    # Stat will return the values and names
    # of all the features associated with the
    # currently-selected chip. This has replaced
    # :features, which is now just an alias for :stat.
    # 
    # 2021-May-31 (pre-release): Now respects @filters
    def stat
      # For each chip, split it by key and value
      raw = read
      # Check that the data is still valid
      if raw.nil? then return nil end
      data = raw.collect do |feature, keys|
        # Is the filter set?
        no_filter = @filters.empty?
        # Is the feature of a type included in the filter?
        included = @filters.include?(keys[:type])
        
        # If the filter is NOT set, OR the keys IS included
        # in the filter, proceed.
        if no_filter or included then
          # If the subfeature option is set, return
          # the subfeature data and the unit.
          if @subs then
            @fmap.call(feature, keys)
          # If the subfeature option is not set, just return
          # the feature type.
          else { feature => keys[:type] } end
        # If filtered and not included, return empty array
        else [] end
      end.flatten # Remove any empty units
      # If format is set, format the output
      if (@fmt and @subs) then data.collect { |item| item.fmt } else data end
    end
    # Pseudo-alias abstract enum to stat, for this class
    def enum(*args) stat end
    
    ##
    # :features is now an alias for :stat,
    # as :stat did not previously respect @filters
    alias :features :stat
    
    ##
    # Get the number of features available for
    # the current name (or total features to be
    # read for all sensors). This overrides the
    # abstract ``.count`` method.
    def count
      data = read
      if !data then return nil end
      # If the data is good
      data.count
    end # End count method
    
    ##
    # Get the number of subfeatures available for
    # the current name (or total features to be
    # read for all sensors).
    def count_sf
      total = 0 # Accumulator
      data = read
      if !data then return nil end
      # If the data is good, continue
      data.each do |_, v|
        # Ignore the :type symbol
        total += (v.select { |item| :type != item } .count)
      end
      total # Return accumulator
    end # End count of subfeatures
    
    ##
    # Raw chip data -- this is unfiltered and unformatted.
    # 
    # This has replaced the previous version of :stat, as
    # :stat unintentionally did not respect the @filters.
    def read
      c = pro_enum(true, @chip_name)
      if Hash === c then
        c[@path][:stat]
      else
        STDERR.puts c
        return nil
      end
    end # End read
  end # End Sensor class
end # End LmSensors append