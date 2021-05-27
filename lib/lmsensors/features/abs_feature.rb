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
      attr_reader :fstruct, :name, :subfs, :type
      
      # Constructor
      def initialize(name, data)
        @name = name
        @type = data[:type]
        @subfs = data
        @subfs.delete(:type)
        @fstruct = {}
      end # End constructor
      
      ##
      # Return just the feature keys
      def feature() { name: @name, type: @type} end
      
      ##
      # Format the output struct
      def fmt
        @fstruct = @subfs.collect do |sfk, sfv|
          # Do not include single-item keys
          if Hash === sfv then
            # Attach the unit type to the subfeature
            { sfk => sfv.merge({ unit: LmSensors::UNITS[@type] }) }
          end
        # Remove empties, merge the subfeature hashes together
        end.compact.reduce Hash.new, :merge
        
        @fstruct
      end # End formatting of new struct type
      
      ##
      # Perform the unit calculations on the new
      # feature struct
      def calculate
        STDERR.puts "'.calculate' not implemented for #{self.class}"
        {}
      end # End calculation method
    end # End abstract Feature class
  end # End Feature module
end # End LmSensors inclusion