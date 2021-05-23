# lib/lmsensors/features/power.rb

# Make sure to include the constants
require_relative "../lm_constants"
require_relative "./abs_feature"

# Append to the main module
module LmSensors
  # Append to the Feature module
  module Feature
    ##
    # The Power class is appended to the LmSensors module
    # to handle analytic post-processing of the FEATURE_POWER type.
    class Power < LmSensors::Feature::GenFeature
      
    end # End Power class
  end # End Feature append
end # End LmSensors inclusion