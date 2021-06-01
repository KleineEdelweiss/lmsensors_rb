# lib/lmsensors/sensors/sensorspawner.rb

# Require the abstract sensor
require_relative "./sensor"

# :nodoc: This module will house the concrete implementation
# :nodoc: of the actual Sensor object types.
module LmSensors
  ##
  # SensorSpawner is a Sensor, unto itself,
  # but it provides no way to format any output
  # and is purely used to construct a list of
  # single Sensors.
  # 
  # This class inherits the SensorsBase class
  # from the C side of the code.
  # 
  # The single Sensors will actually provide
  # the information usable by the client.
  class SensorSpawner < LmSensors::AbsSensor
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
    # Enumerate the available chips for the specified
    # name that was set (or all chips, if no name).
    # 
    # This will return an array of either ALL
    # the available chips or the selected
    # chip set by 'set_name'.
    def enum(name=@chip_name)
      chips = pro_enum(nil, name)
      if Hash === chips then
        chips.collect do |index, chip|
          item = LmSensors::Sensor.new
          item.locate index
          item.set_fmap(@fmap)
          item
        end
      else
        STDERR.puts chips
        nil
      end
    end # End sensor chip enumerator
    
    ##
    # Select a specific chip by its path.
    def locate(path, set=false)
      dir = path_valid?(path)
      # Return early, if the path is invalid
      if !dir then return dir end
      
      # Otherwise, continue
      items = []
      if dir then
        data = enum
        if Array === data then
          # Only proceed if the data is good
          items = data.select { |s| s.path == dir }
        else return nil end
      end.flatten
      if items.length == 1 then
        item = items[0]
        if set then set_name(item.name) end
        item
      else nil end
    end # End locate of specific chip
  end # End SensorSpawner class
end # End LmSensors append