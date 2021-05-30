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
  # Wrap the module functions
  # 
  # Contains: 'pro_init', 'pro_cleanup'
  def self.init(filename=nil) self.pro_init(filename) end
  def self.cleanup() self.pro_cleanup end
  
  ##
  # For compatibility purposes, as this was
  # being tested by some people, Sensors is now
  # purely an alias of SensorSpawner.
  Sensors = LmSensors::SensorSpawner
end # End LmSensors module