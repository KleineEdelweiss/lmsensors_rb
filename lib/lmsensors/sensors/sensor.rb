# lib/lmsensors/sensors/sensors.rb

# Require the abstract sensor
require_relative "./abssensor"

##
# This module will house the concrete implementation
# of the actual Sensor object types.
module LmSensors
  ##
  # Sensor is a concrete implementation
  # of the AbsSensor. This implementation
  # is a specific object dedicated to an
  # individual sensor chip.
  class Sensor < LmSensors::AbsSensor
    attr_reader :path, :adapter
    ##
    # Find a device sensors by its path, in such
    # a case where the app already has a device from
    # sysfs or similar and needs to attach them together.
    # 
    # Sets the name of the sensor, as well, so this should
    # be used as an instance.
    def locate(path)
      # Check that the path argument is a string
      if (!String === path) then
        STDERR.puts "::Sensor ERROR:: Path must be string!"
        return nil
      end # End check for correct path
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
      pro_enum(nil, nil).then do |sensors|
        # Return early, if it's not in the keys
        if !sensors.keys.include?(path) then
          STDERR.puts "Path does not have an associated sensor"
          return nil
        end # End check for valid sensor path
        
        # Set the data and return the chip name
        data = sensors[path]
        @chip_name = data[:name]
        @adapter = data[:adapter]
        @path = data[:path]
        @chip_name
      end # End enumeration handler
    end # End locate by path
    
    ##
    # Stat will return the values and names
    # of all the features associated with the
    # currently-selected chip.
    def stat() pro_enum(true, @chip_name)[@path][:stat] end
    # Pseudo-alias abstract enum to stat, for this class
    def enum(*args) stat end
    
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
        feats = v[:stat].collect do |_k, sv|
          # Ignore the :type symbol
          total += (sv.select { |item| :type != item } .count)
        end
      end
      total # Return accumulator
    end # End count of subfeatures
    
    ##
    # Return a list of features for the selected
    # chip. As this 3rd implementation of the class
    # only supports a single chip per sensor, this
    # is almost ret-conning the 2nd version.
    def features
      # For each chip, split it by key and value
      data = stat.collect do |feature, keys|
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
            LmSensors.fmap(feature, keys)
          # If the subfeature option is not set, just return
          # the feature type.
          else { feature => keys[:type] } end
        # If filtered and not included, return empty array
        else [] end
      end.flatten # Remove any empty units
    end # End features collector
  end # End Sensor class
end # End LmSensors append