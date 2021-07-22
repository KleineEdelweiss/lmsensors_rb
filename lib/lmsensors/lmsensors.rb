# lib/lmsensors/lmsensors.rb

# Base requires
require "lmsensors_base.so"
require_relative "./lm_constants"

require_relative "./sensors/sensorspawner"
require_relative "./sensors/sensor"

require_relative "./feature"

##
# LmSensors is the wrapping module for the entire
# lm-sensors library. This module provides the ability
# to initialize for and clean up resources from it, to
# generate Sensor objects that can be used to monitor
# specific pieces of hardware, as desired, and to generate
# a SensorSpawner to enumerate what sensors are available.
module LmSensors
  ##
  # Wraps the 'pro_init' function to initialize the sensors
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