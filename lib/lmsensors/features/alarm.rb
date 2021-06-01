# lib/lmsensors/features/alarm.rb

# Make sure to include the constants
require_relative "../lm_constants"
require_relative "./abs_feature"

# :nodoc: Append to the main module
module LmSensors
  # :nodoc: Append to the Feature module
  module Feature
    ##
    # Default formatting proc for ALARM types
    FMT_ALARM = lambda do |feature|
      # Formatted structure
      unit = feature.unit
      out = feature.feature
      # Don't need to return unit, as it is proc for this feature type
      out.delete(:unit)
      
      # Format the outputs
      feature.subfs.map do |k, v|
        # Only check is alarm is enabled.
        # The other option SSF_INTRUDE_BEEP
        # is not formatted in the normal sensor program
        if v[:subtype] == SSF_INTRUDE_ALARM then
          out[k] = unit.call(v[:value]) end
      end # End value mapper for alarm
      out
    end # End default alarm formatter
    
    ##
    # The Alarm class is appended to the LmSensors module
    # to handle analytic post-processing of the FEATURE_INTRUSION type.
    class Alarm < LmSensors::Feature::GenFeature
      def def_fmt() @default_formatter = LmSensors::Feature::FMT_ALARM end
    end # End Alarm class
  end # End Feature append
end # End LmSensors inclusion