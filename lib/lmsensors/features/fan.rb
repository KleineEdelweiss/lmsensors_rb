# lib/lmsensors/featureseatures/fan.rb

# Make sure to include the constants
require_relative "../lm_constants"
require_relative "./abs_feature"

# Append to the main module
module LmSensors
  # Append to the Feature module
  module Feature
    ##
    # The Fan class is appended to the LmSensors module
    # to handle analytic post-processing of the FEATURE_FAN type.
    class Fan < LmSensors::Feature::GenFeature
      #attr_reader :
      # Format constant for the fan type
      FORMAT = { SSF_FAN_INPUT => :input, SSF_FAN_MIN => :min, SSF_FAN_MAX => :max, }
      
      ##
      # Override the default formatter
      def def_fmt() @default_formatter = LmSensors::Feature::FMT_FAN end
    end # End Fan class
  end # End Feature append
end # End LmSensors inclusion