# lib/lmsensors/features/current.rb

# Make sure to include the constants
require_relative "../lm_constants"
require_relative "./abs_feature"

# Append to the main module
module LmSensors
  # Append to the Feature module
  module Feature
    ##
    # The Current class is appended to the LmSensors module
    # to handle analytic post-processing of the FEATURE_CURR type.
    class Current < LmSensors::Feature::GenFeature
      
    end # End Current class
  end # end Feature append
end # End LmSensors inclusion