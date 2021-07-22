# lib/lmsensors/features/beep.rb

# Make sure to include the constants
require_relative "../lm_constants"
require_relative "./abs_feature"

# :nodoc: Append to the main module
module LmSensors
  # :nodoc: Append to the Feature module
  module Feature
    ##
    # Default formatting proc for BEEP types
    FMT_BEEP = lambda do |feature|
      unit = feature.unit
      out = feature.feature
      # Don't need to return unit, as it is proc for this feature type
      out.delete(:unit)
      
      # Format the outputs
      feature.subfs.map do |k, v|
        if v[:value] then out[k] = unit.call(v[:value]) end
      end # End value mapper for beep
      out
    end # End default beep formatter
    
    ##
    # The Beep class is appended to the LmSensors module
    # to handle analytic post-processing of the FEATURE_BEEP_ENABLE type.
    class Beep < LmSensors::Feature::GenFeature
      def def_fmt() @default_formatter = LmSensors::Feature::FMT_BEEP end
    end # End Beep class
  end # End Feature append
end # End LmSensors inclusion