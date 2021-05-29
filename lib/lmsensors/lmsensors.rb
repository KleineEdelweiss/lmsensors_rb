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
  # The fmap method maps the feature type to the
  # subclass that will be used to handle
  # formatting and analytic post-processing.
  def self.fmap(name, f_obj)
    case f_obj[:type]
    when SF_IN
      Feature::Voltage.new name, f_obj
    when SF_CURR
      Feature::Current.new name, f_obj
    when SF_POWER
      Feature::Power.new name, f_obj
    when SF_TEMP
      Feature::Temp.new name, f_obj
    when SF_FAN
      Feature::Fan.new name, f_obj
    #when SF_INTRUSION
    #  Feature::Alarm.new name, f_obj
    #when SF_BEEP_ENABLE
    #  Feature::Beep.new name, f_obj
    else
      Feature::GenFeature.new name, f_obj
    end
  end # End feature mapper
  
  ##
  # For compatibility purposes, as this was
  # being tested by some people, Sensors is now
  # purely an alias of SensorSpawner.
  Sensors = LmSensors::SensorSpawner
end # End LmSensors module