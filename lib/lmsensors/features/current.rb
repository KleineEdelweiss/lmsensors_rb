# lib/lmsensors/features/current.rb

# Make sure to include the constants
require_relative "../lm_constants"
require_relative "./abs_feature"

# :nodoc: Append to the main module
module LmSensors
  # :nodoc: Append to the Feature module
  module Feature
    ##
    # Default current formatting proc
    FMT_CURR = lambda do |feature|
      # Formatted structure
      unit = feature.unit
      out = feature.feature
      tmp = { input: nil, max: nil }
      
      # Format the outputs
      # Strip each, in case the unit is empty
      feature.subfs.values.map do |v|
        case v[:subtype]
        when SSF_CURR_INPUT
          tmp[:input] = v[:value]
          out[:input] = "#{v[:value].round(2)} #{unit}".strip
        when SSF_CURR_MAX
          if v[:value] != 0 then
            tmp[:max] = v[:value]
            out[:max] = "#{v[:value].round(2)} #{unit}".strip
          end
        when SSF_CURR_CRIT
          if v[:value] != 0 then
            tmp[:crit] = v[:value]
            out[:crit] = "#{v[:value].round(2)} #{unit}".strip
          end
        when SSF_CURR_MIN
          if v[:value] != 0 then out[:min] = "#{v[:value].round(2)} #{unit}".strip end
        end
      end # End value mapper for fan
      
      # Set the check symbols
      # Symbol for input, symbol for limit
      syi, syl = :input, :max
      
      # Calculate the percentage of current max
      # :percent is against max, for current
      if tmp[syl] and tmp[syi] then
        perc = ((tmp[syi].to_f / tmp[syl]) * 100).round(2)
        out[:percent] = "#{perc}%".strip
      end # Only if both are present
      
      syl = :crit
      
      # Calculate the percentage of current crit
      if tmp[syl] and tmp[syi] then
        perc = ((tmp[syi].to_f / tmp[syl]) * 100).round(2)
        out[:percent_crit] = "#{perc}%".strip
      end # Only if both are present
      out
    end # End current proc
    
    ##
    # The Current class is appended to the LmSensors module
    # to handle analytic post-processing of the FEATURE_CURR type.
    class Current < LmSensors::Feature::GenFeature
      def def_fmt() @default_formatter = LmSensors::Feature::FMT_CURR end
    end # End Current class
  end # end Feature append
end # End LmSensors inclusion