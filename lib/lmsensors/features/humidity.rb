# lib/lmsensors/features/voltage.rb

# Make sure to include the constants
require_relative "../lm_constants"
require_relative "./abs_feature"

# :nodoc: Append to the main module
module LmSensors
  # :nodoc: Append to the Feature module
  module Feature
    ##
    # Default humidity formatting proc.
    # 
    # I cannot test this on any of my systems,
    # so it might need to be overridden.
    FMT_HUMIDITY = lambda do |feature|
      # Formatted structure
      unit = feature.unit
      out = feature.feature
      
      # Format the outputs
      feature.subfs.map do |k, v|
        out[k] = "#{v[:value].round(2)}#{unit}"
      end # End value mapper for humidity
      out
    end # End humidity proc
    
    ##
    # The Humidity class is appended to the LmSensors module
    # to handle analytic post-processing of the FEATURE_HUMIDITY type.
    class Humidity < LmSensors::Feature::GenFeature
      def def_fmt() @default_formatter = LmSensors::Feature::FMT_HUMIDITY end
    end # End Humidity class
  end # End Feature append
end # End LmSensors inclusion