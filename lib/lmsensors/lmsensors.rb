# lib/lmsensors/lmsensors.rb

# Base requires
require_relative "../lmsensors_base/lmsensors_base"
require_relative "./lm_constants"

require_relative "./sensors/sensorspawner"
require_relative "./sensors/sensor"

require_relative "./feature"

##
# LmSensors is the wrapping module for the entire
# lm-sensors library.
module LmSensors
  ##
  # Wraps the 'pro_init' function to initialzie the sensors
  def self.init(filename=nil) self.pro_init(filename) end
  
  ##
  # Wraps the 'pro_cleanup' function to release the resources
  def self.cleanup() self.pro_cleanup end
  
  ##
  # For compatibility purposes, as this was
  # being tested by some people, Sensors is now
  # purely an alias of SensorSpawner.
  Sensors = LmSensors::SensorSpawner
end # End LmSensors module