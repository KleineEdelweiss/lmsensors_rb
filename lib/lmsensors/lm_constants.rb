# lib/lmsensors/lm_constants.rb

##
# This file simply adds in the constants mappings to
# the LmSensors module, because there are so many,
# and it is inconvenient to keep them all in one.
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
    SF_ENERGY => "J", # Energy, Joules
    SF_CURR => "A", # Current, Amps
    SF_HUMIDITY => "%", # Humidity, percent
    # Skips here
    SF_VID => "V", # Vid -- this is in Volts
    SF_INTRUSION => CHK_ENABLE, # Intrusion
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
  SSF_SUBTYPES = {
    # Voltages
    SF_IN => {
      # Inputs
      input: SSF_IN_INPUT,
      
      # Edge readings
      lowest: SSF_IN_LOW,
      highest: SSF_IN_HIGH,
      
      # Minima and maxima
      min: SSF_IN_MIN,
      max: SSF_IN_MAX,
      
      # Critical levels
      lcrit: SSF_IN_LCRIT,
      crit: SSF_IN_CRIT,
      
      # Averages
      average: SSF_IN_AVG,
    },
    # Currents
    SF_CURR => {
      # Inputs
      input: SSF_CURR_INPUT,
      
      # Edge readings
      lowest: SSF_CURR_LOW,
      highest: SSF_CURR_HIGH,
      
      # Minima and maxima
      min: SSF_CURR_MIN,
      max: SSF_CURR_MAX,
      
      # Critical levels
      lcrit: SSF_CURR_LCRIT,
      crit: SSF_CURR_CRIT,
      
      # Averages
      average: SSF_CURR_AVG,
    },
    # Power
    SF_POWER => {
      # Inputs
      input: SSF_POWER_INPUT,
      input_low: SSF_POWER_INPUT_LOW,
      input_high: SSF_POWER_INPUT_HIGH,
      
      # Minima and maxima
      min: SSF_POWER_MIN,
      max: SSF_POWER_MAX,
      
      # Critical levels
      lcrit: SSF_POWER_LCRIT,
      crit: SSF_POWER_CRIT,
      
      # Averages
      average: SSF_POWER_AVG,
      average_low: SSF_POWER_AVG_LOW,
      average_high: SSF_POWER_AVG_HIGH,
      
      # Caps
      cap: SSF_POWER_CAP,
      cap_hyst: SSF_POWER_CAP_HYST,
    },
    
    # Temperatures
    SF_TEMP => {
      # Inputs
      input: SSF_TEMP_INPUT,
      
      # Edge readings
      lowest: SSF_TEMP_LOW,
      highest: SSF_TEMP_HIGH,
      
      # Minima and maxima + hysteresis
      min: SSF_TEMP_MIN,
      min_hyst: SSF_TEMP_MIN_HYST,
      max: SSF_TEMP_MAX,
      max_hyst: SSF_TEMP_MAX_HYST,
      
      # Critical and emergency levels + hysteresis
      lcrit: SSF_TEMP_LCRIT,
      lcrit_hyst: SSF_TEMP_LCRIT_HYST,
      crit: SSF_TEMP_CRIT,
      crit_hyst: SSF_TEMP_CRIT_HYST,
      emergency: SSF_TEMP_EMERG,
      emergency_hyst: SSF_TEMP_EMERG_HYST,
    },
    # Fans
    # Fan sensors have a simple structure that is self-explanatory.
    SF_FAN => { input: SSF_FAN_INPUT, min: SSF_FAN_MIN, max: SSF_FAN_MAX, },
  } # End SSF subtypes
end # End LmSensors constants maps