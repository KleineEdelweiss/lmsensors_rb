# lib/lmsensors/sensors/sensorspawner.rb

# Require the abstract sensor
require_relative "./sensor"

##
# This module will house the concrete implementation
# of the actual Sensor object types.
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
    # This will return a hash of either ALL
    # the available chips or the selected
    # chip set by 'set_name'.
    def enum(name=@chip_name) 
      pro_enum(nil, name).collect do |index, chip|
        item = LmSensors::Sensor.new
        item.locate index
        item
      end
    end # End sensor chip enumerator
  end # End SensorSpawner class
end # End LmSensors append