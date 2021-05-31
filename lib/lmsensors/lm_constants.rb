# lib/lmsensors/lm_constants.rb

# Require the base implementation
require_relative "../lmsensors_base/lmsensors_base"

##
# This file simply adds in the constants mappings to
# the LmSensors module, because there are so many,
# and it is inconvenient to keep them all in one.
module LmSensors
  ##
  # The default feature map method maps the feature 
  # type to the subclass that will be used to handle
  # formatting and analytic post-processing.
  DEF_FMAP = lambda do |name, f_obj|
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
    when SF_HUMIDITY
      Feature::Humidity.new name, f_obj
    when SF_INTRUSION
      Feature::Alarm.new name, f_obj
    when SF_BEEP_ENABLE
      Feature::Beep.new name, f_obj
    else
      Feature::GenFeature.new name, f_obj
    end
  end # End default feature mapper
  
  ##
  # CHK_BEEP uses the same formatting as the print_chip_beep_enable
  # from the sensors program chips.c.
  CHK_BEEP = lambda { |v| v < 0.5 ? "disabled" : "enabled" }
  
  ##
  # CHK_ALARM uses the same formatting as the print_chip_intrusion
  # from the sensors program chips.c.
  CHK_ALARM = lambda { |v| v.zero? ? "OK" : "ALARM" }
  
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
    SF_ENERGY => "J", # Energy, Joules
    SF_CURR => "A", # Current, Amps
    SF_HUMIDITY => "% RH", # Humidity, percent
    # Skips here
    SF_VID => "V", # Vid -- this is in Volts
    SF_INTRUSION => CHK_ALARM, # Intrusion
    # Skips here, again
    SF_BEEP_ENABLE => CHK_BEEP, # Beep enabled, true if gte 0.5
  } # End default units enum
  
  ##
  # This hash maps commonly-used limit types from
  # the SENSORS_SUBFEATURE_* constants.
  # 
  # I have not included ALL the subfeatures types,
  # because there are around 100 of them, and most of
  # them provide no post-processing value. I have, however,
  # included the following subfeature groups for
  # the _POWER_, _IN_, _CURR_, and _FAN_ categories:
  # 
  # MIN, MAX, a couple HYST (hysteresis) types, INPUT,
  # and a couple AVERAGE types.
  # 
  # NOTE: For the MOST part, the below list is provided
  # for convenience, only. You can use it to create your
  # own mappers, if you are not sure what subtypes are
  # included in the normal feature objects.
  # 
  # I had actually considered removing everything below,
  # but I realized that simply swapping the keys with the
  # values actually provides a simpler way for others to
  # access the types and provide some default key types
  # they might want to use in their subclasses, even if it's 
  # somewhat redundant.
  SSF_SUBTYPES = {
    # Voltages
    SF_IN => {
      # Inputs
      SSF_IN_INPUT => :input,
      
      # Edge readings
      SSF_IN_LOW => :lowest,
      SSF_IN_HIGH => :highest,
      
      # Minima and maxima
      SSF_IN_MIN => :min,
      SSF_IN_MAX => :max,
      
      # Critical levels
      SSF_IN_LCRIT => :lcrit,
      SSF_IN_CRIT => :crit,
      
      # Averages
      SSF_IN_AVG => :average,
    },
    # Currents
    SF_CURR => {
      # Inputs
      SSF_CURR_INPUT => :input,
      
      # Edge readings
      SSF_CURR_LOW => :lowest,
      SSF_CURR_HIGH => :highest,
      
      # Minima and maxima
      SSF_CURR_MIN => :min,
      SSF_CURR_MAX => :max,
      
      # Critical levels
      SSF_CURR_LCRIT => :lcrit,
      SSF_CURR_CRIT => :crit,
      
      # Averages
      SSF_CURR_AVG => :average,
    },
    # Power
    SF_POWER => {
      # Inputs
      SSF_POWER_INPUT => :input,
      SSF_POWER_INPUT_LOW => :input_low,
      SSF_POWER_INPUT_HIGH => :input_high,
      
      # Minima and maxima
      SSF_POWER_MIN => :min,
      SSF_POWER_MAX => :max,
      
      # Critical levels
      SSF_POWER_LCRIT => :lcrit,
      SSF_POWER_CRIT => :crit,
      
      # Averages
      SSF_POWER_AVG => :average,
      SSF_POWER_AVG_LOW => :average_low,
      SSF_POWER_AVG_HIGH => :average_high,
      
      # Caps
      SSF_POWER_CAP => :cap,
      SSF_POWER_CAP_HYST => :cap_hyst,
    },
    
    # Temperatures
    SF_TEMP => {
      # Inputs
      SSF_TEMP_INPUT => :input,
      
      # Edge readings
      SSF_TEMP_LOW => :lowest,
      SSF_TEMP_HIGH => :highest,
      
      # Minima and maxima + hysteresis
      SSF_TEMP_MIN => :min,
      SSF_TEMP_MIN_HYST => :min_hyst,
      SSF_TEMP_MAX => :max,
      SSF_TEMP_MAX_HYST => :max_hyst,
      
      # Critical and emergency levels + hysteresis
      SSF_TEMP_LCRIT => :lcrit,
      SSF_TEMP_LCRIT_HYST => :lcrit_hyst,
      SSF_TEMP_CRIT => :crit,
      SSF_TEMP_CRIT_HYST => :crit_hyst,
      SSF_TEMP_EMERG => :emergency,
      SSF_TEMP_EMERG_HYST => :emergency_hyst,
    },
    # Fans
    # Fan sensors have a simple structure that is self-explanatory.
    SF_FAN => { SSF_FAN_INPUT => :input, SSF_FAN_MIN => :min, SSF_FAN_MAX => :max, },
  } # End SSF subtypes
end # End LmSensors constants maps