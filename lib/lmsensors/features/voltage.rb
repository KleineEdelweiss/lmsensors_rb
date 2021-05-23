# lib/lmsensors/features/voltage.rb

# Make sure to include the constants
require_relative "../lm_constants"
require_relative "./abs_feature"

# Append to the main module
module LmSensors
  # Append to the Feature module
  module Feature
    ##
    # The Voltage class is appended to the LmSensors module
    # to handle analytic post-processing of the FEATURE_IN type.
    class Voltage  < LmSensors::Feature::GenFeature
      
    end # End Voltage class
  end # End Feature append
end # End LmSensors inclusion