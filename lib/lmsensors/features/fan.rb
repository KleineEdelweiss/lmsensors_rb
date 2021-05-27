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
      # Format the fan subfeature to also include
      # current speed as a percentage of max.
      def fmt
        @subfs.map do |key, val|
          # Format all the other subtypes
          stype = val[:subtype]
          skey = FORMAT[stype]
          if skey then
            @fstruct[skey] = val[:value] end
          @fstruct[key] = "#{val[:value].round} #{@ftype}"
        end # End mapping loop
        # Format the outputs
        @fstruct[:input_fmt] = "#{@fstruct[:input].round} #{@ftype}"
        @fstruct[:min_fmt] = "#{@fstruct[:min].round} #{@ftype}"
        @fstruct[:max_fmt] = "#{@fstruct[:max].round} #{@ftype}"
        
        # Format the usage percent
        perc = ((@fstruct[:input].to_f / @fstruct[:max]) * 100).round(2)
        @fstruct[:usage] = "#{perc}%"
        @fstruct
      end # End formatter
    end # End Fan class
  end # End Feature append
end # End LmSensors inclusion