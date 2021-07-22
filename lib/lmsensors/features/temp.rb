# lib/lmsensors/features/temp.rb

# Make sure to include the constants
require_relative "../lm_constants"
require_relative "./abs_feature"

# :nodoc: Append to the main module
module LmSensors
  # :nodoc: Append to the Feature module
  module Feature
    ##
    # Default temperature formatting proc
    FMT_TEMP = lambda do |feature|
      # Formatted structure
      unit = feature.unit
      out = feature.feature
      tmp = { input: nil, max: nil }
      
      # Format the outputs
      # Strip each, in case the unit is empty
      feature.subfs.values.map do |v|
        if v[:value] then
          case v[:subtype]
          when SSF_TEMP_INPUT
            tmp[:input] = v[:value]
            out[:input] = "#{v[:value].round(2)} #{unit}".strip
          when SSF_TEMP_MAX
            if v[:value] != 0 then
              tmp[:max] = v[:value]
              out[:max] = "#{v[:value].round(2)} #{unit}".strip
            end
          when SSF_TEMP_CRIT
            if v[:value] != 0 then
              tmp[:crit] = v[:value]
              out[:crit] = "#{v[:value].round(2)} #{unit}".strip
            end
          when SSF_TEMP_MIN
            if v[:value] != 0 then out[:min] = "#{v[:value].round(2)} #{unit}".strip end
          end
        end
      end # End value mapper for fan
      
      # Set the check symbols
      # Symbol for input, symbol for limit
      syi, syl = :input, :max
      
      # Calculate the percentage of voltage max
      # :percent is against max, for voltage
      if tmp[syl] and tmp[syi] then
        perc = ((tmp[syi].to_f / tmp[syl]) * 100).round(2)
        out[:percent] = "#{perc}%".strip
      end # Only if both are present
      
      syl = :crit
      
      # Calculate the percentage of voltage crit
      if tmp[syl] and tmp[syi] then
        perc = ((tmp[syi].to_f / tmp[syl]) * 100).round(2)
        out[:percent_crit] = "#{perc}%".strip
      end # Only if both are present
      out
    end # End temp proc
    
    ##
    # The Temp class is appended to the LmSensors module
    # to handle analytic post-processing of the FEATURE_TEMP type.
    class Temp < LmSensors::Feature::GenFeature
      def def_fmt() @default_formatter = LmSensors::Feature::FMT_TEMP end
    end # End Temp class
  end # End Feature append
end # End LmSensors inclusion