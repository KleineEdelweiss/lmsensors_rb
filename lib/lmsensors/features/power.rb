# lib/lmsensors/features/power.rb

# Make sure to include the constants
require_relative "../lm_constants"
require_relative "./abs_feature"

# Append to the main module
module LmSensors
  # Append to the Feature module
  module Feature
    ##
    # Default power formatting proc
    FMT_POWER = lambda do |feature|
      # Formatted structure
      unit = feature.unit
      out = feature.feature
      tmp = { input: nil, max: nil }
      
      # Format the outputs
      # Strip each, in case the unit is empty
      feature.subfs.values.map do |v|
        case v[:subtype]
        when SSF_POWER_INPUT
          out[:input] = "#{v[:value].round(2)} #{unit}".strip
        when SSF_POWER_AVG
          tmp[:average] = v[:value]
          out[:average] = "#{v[:value].round(2)} #{unit}".strip
        when SSF_POWER_MAX
          tmp[:max] = v[:value]
          out[:max] = "#{v[:value].round(2)} #{unit}".strip
        when SSF_POWER_CRIT
          tmp[:crit] = v[:value]
          out[:crit] = "#{v[:value].round(2)} #{unit}".strip
        when SSF_POWER_CAP
          tmp[:cap] = v[:value]
          out[:cap] = "#{v[:value].round(2)} #{unit}".strip
        when SSF_POWER_MIN
          out[:min] = "#{v[:value].round(2)} #{unit}".strip
        end
      end # End value mapper for fan
      
      # Set the check symbols
      # Symbol for input, symbol for limit
      syi, syl = :average, :cap
      
      # Calculate the percentage of power cap
      # :percent is against cap for power, and it is
      # in respect to :average, not :input, as not all
      # sensors will use input for power.
      if tmp[syl] and tmp[syi] then
        perc = ((tmp[syi].to_f / tmp[syl]) * 100).round(2)
        out[:percent] = "#{perc}%".strip
      end # Only if both are present
      
      syl = :max
      
      # Calculate the percentage of power max
      if tmp[syl] and tmp[syi] then
        perc = ((tmp[syi].to_f / tmp[syl]) * 100).round(2)
        out[:percent_max] = "#{perc}%".strip
      end # Only if both are present
      
      syl = :crit
      
      # Calculate the percentage of power crit
      if tmp[syl] and tmp[syi] then
        perc = ((tmp[syi].to_f / tmp[syl]) * 100).round(2)
        out[:percent_crit] = "#{perc}%".strip
      end # Only if both are present
      out
    end # End power proc
    
    ##
    # The Power class is appended to the LmSensors module
    # to handle analytic post-processing of the FEATURE_POWER type.
    class Power < LmSensors::Feature::GenFeature
      def def_fmt() @default_formatter = LmSensors::Feature::FMT_POWER end
    end # End Power class
  end # End Feature append
end # End LmSensors inclusion