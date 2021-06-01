# lib/lmsensors/featureseatures/fan.rb

# Make sure to include the constants
require_relative "../lm_constants"
require_relative "./abs_feature"

# :nodoc: Append to the main module
module LmSensors
  # :nodoc: Append to the Feature module
  module Feature
    ##
    # Default formatting proc for
    # the X_FAN subtype.
    FMT_FAN = lambda do |feature|
      # Formatted structure
      unit = feature.unit
      out = feature.feature
      tmp = { input: nil, max: nil }
      
      # Format the outputs
      # Strip each, in case the unit is empty
      feature.subfs.values.map do |v|
        case v[:subtype]
        when SSF_FAN_INPUT
          tmp[:input] = v[:value]
          out[:input] = "#{v[:value]} #{unit}".strip
        when SSF_FAN_MAX
          tmp[:max] = v[:value]
          out[:max] = "#{v[:value]} #{unit}".strip
        when SSF_FAN_MIN
          out[:min] = "#{v[:value]} #{unit}".strip
        end
      end # End value mapper for fan
      
      # Calculate the percentage of max speed of fan
      if tmp[:max] and tmp[:input] then
        perc = ((tmp[:input].to_f / tmp[:max]) * 100).round(2)
        out[:percent] = "#{perc}%".strip
      end # Only if both are present
      out
    end # End default fan formatter
    
    ##
    # The Fan class is appended to the LmSensors module
    # to handle analytic post-processing of the FEATURE_FAN type.
    class Fan < LmSensors::Feature::GenFeature
      ##
      # Override the default formatter
      def def_fmt() @default_formatter = LmSensors::Feature::FMT_FAN end
    end # End Fan class
  end # End Feature append
end # End LmSensors inclusion