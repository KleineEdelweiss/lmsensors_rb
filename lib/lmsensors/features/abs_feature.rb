# lib/lmsensors/features/abs_feature.rb

# Make sure to include the constants
require_relative "../lm_constants"

# Append to the main module
module LmSensors
  ##
  # Feature module is used to handle the formatting
  # and inheritance of various feature types.
  module Feature
    ##
    # The generic GenFeature class is appended to the LmSensors
    # to handle generic formatting on feature types that
    # generally will not need additional post-processing.
    class GenFeature
      attr_reader :data, :fstruct
      
      # Constructor
      def initialize(data)
        @data = data
      end # end constructor
      
      ##
      # Format the output struct
      def fmt
        @fstruct = @data.collect do |sfk, sfv|
          # Do not include single-item keys
          if Hash === sfv then
            # Attach the unit type to the subfeature
            { sfk => sfv.merge({ unit: LmSensors::UNITS[sfv[:type]] }) }
          end
        # Remove empties, merge the subfeature hashes together
        end.compact.reduce Hash.new, :merge
        
        @fstruct
      end # End formatting of new struct type
    end # End abstract Feature class
  end # End Feature module
end # End LmSensors inclusion