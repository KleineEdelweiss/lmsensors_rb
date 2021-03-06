# lib/lmsensors/features/abs_feature.rb

# Make sure to include the constants
require_relative "../lm_constants"

# :nodoc: Append to the main module
module LmSensors
  ##
  # Feature module is used to handle the formatting
  # and inheritance of various feature types.
  module Feature
    ##
    # Base formatting for anything else.
    # This pretty much just converts a general
    # feature object into a hash, so it can be
    # indexed in post-processing.
    BASE_FMT = lambda do |feature|
      # Attach the main feature name and unit type
      fstruct = { name: feature.name, type: feature.type, unit: feature.unit }
      # Merge the subfeatures
      fstruct.merge(feature.subfs)
    end # End base formatter proc
    
    ##
    # The generic GenFeature class is appended to the LmSensors
    # to handle generic formatting on feature types that
    # generally will not need additional post-processing.
    class GenFeature
      ##
      # GenFeature :default_formatter is BASE_FMT, which returns a
      # simple representation of the sensor subfeatures, if no
      # clear formatting can be determined.
      attr_reader :default_formatter
      ##
      # GenFeature :name is the name of the feature, such as ':temp1'
      attr_reader :name
      ##
      # GenFeature :subfs is a list/array of the subfeatures for this feature
      attr_reader :subfs
      ##
      # GenFeature :type is the type of the feature, such as SF_TEMP or SF_FAN
      attr_reader :type
      ##
      # GenFeature :unit is the default unit that is likely desired to
      # represent subfeatures in this feature.
      #   Example: :temp1 may have :temp1_input and :temp1_crit, but both
      #     would be formatted with °C, which is returned from
      #     LmSensors::UNITS[SF_TEMP]
      attr_reader :unit
      
      ##
      # Constructor
      def initialize(name, data)
        # Attach the default formatter
        def_fmt
        # Attach the base data for this instance
        @name, @type, @subfs = name, data[:type], data
        @subfs.delete(:type) # Remove :type from the hash (for cleaner iteration)
        @unit = LmSensors::UNITS[@type] # Units
      end # End constructor
      
      ##
      # Return just the feature keys
      def feature() { name: @name, type: @type, unit: @unit } end
      
      ##
      # Set the default formatter for the subclass.
      # If not overridden, will be be the default for
      # the abstract general class.
      def def_fmt() @default_formatter = LmSensors::Feature::BASE_FMT end
      
      ##
      # Format the output struct. This uses
      # a default formatter, but any desired formatting
      # function can be passed. The formatter should be
      # a lambda or proc type.
      def fmt(callback=@default_formatter)
        #puts "Abstract formatter for #{self.class}"
        # If the callback is the wrong type, sue the default
        cb = Proc === callback ? callback : @default_formatter
        cb.call(self)
      end # End formatting of new struct type
    end # End abstract Feature class
  end # End Feature module
end # End LmSensors inclusion