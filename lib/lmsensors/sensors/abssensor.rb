# lib/lmsensors/sensors/abssensors.rb

# Requires
require_relative "../../lmsensors_base/lmsensors_base"
require_relative "../lm_constants"
require_relative "../feature"

##
# This module will house the abstract implementation
# of a general sensor-type object.
module LmSensors
  ##
  # AbsSensor is an abstract representation of
  # a sensor-type object and provides a base interface
  # for required functions (operates like a trait).
  class AbsSensor < LmSensors::SensorsBase
    ##
    # AbsSensor :chip_name is the name sensors returns for the chip
    # 
    # AbsSensor :filters are the selected feature types to return for your use case
    # 
    # AbsSensor :fmap is a custom formatter map or the default DEF_FMAP
    # 
    # AbsSensor :fmt is a boolean of whether or not to return the data formatted
    # 
    # AbsSensor :subs is whether to return the subfeatures or just the feature
    #   and its type
    attr_reader :chip_name, :filters, :fmap, :fmt, :subs
    
    ##
    # Constructor
    def initialize
      pro_initialize
      unset_filters
      @fmt = @subs = false
      @fmap = LmSensors::DEF_FMAP
    end # End constructor
    
    ##
    # Get the chip_name
    def name() @chip_name end
    
    ##
    # Set the sensor's filters, the types that
    # will be returned on '.features'.
    def set_filters(arr)
      if Array === arr then
        @filters = arr.select { |item| LmSensors::UNITS.include? item } .sort
      else STDERR.puts "::Sensors ERROR:: Filters must be an array" end
    end # End set filters
    
    ##
    # Unset the filters for this sensor
    def unset_filters() @filters = [] end
    
    ##
    # Toggle whether this sensor also returns
    # subfeatures on a feature list request.
    def toggle_subs() @subs = !@subs end
    
    ##
    # Toggle if the sensor will report with
    # formatted output or unformatted. Default
    # is to report unformatted.
    def toggle_fmt() @fmt = !@fmt end
    
    ##
    # Set the format mapper for the different types.
    # This method should receive a proc that maps to different
    # feature formatters.
    def set_fmap(map)
      # Only accept a proc/lambda for format mapping
      if Proc === map then
        if map.arity != 2 then
          if !$LmSensorsIgnArity then
            STDERR.puts <<~EMSG
            ::SensorSpawner WARNING:: @fmap arity should be 2 and will
            NOT WORK without being overridden in a custom subclass.
            
            If you are receiving this message, and you have already
            overridden the subclasses and format handling, you should
            set the global variable $LmSensorsIgnArity to 'true'.
            
            This is only a warning and will not stop the map from
            being set, even if it is invalid.
            
            This warning will NOT be displayed again in this run.
            EMSG
            $LmSensorsIgnArity = true
          end
          @fmap = map
        end
      else # If it's not a proc, spit out an error
        STDERR.puts "::Sensors ERROR:: Format map must be a proc/lambda"
      end
    end # End format mapper
    
    ##
    # Reset the formatting map
    def reset_fmap() @fmap = LmSensors::DEF_FMAP end
    
    ##
    # Abstract enum must be implemented
    # by subclasses
    def enum(*args)
      STDERR.puts "::AbsSensor ERROR:: Abstract 'enum' not implemented for #{self.class}"
      []
    end # End abstract enum
    
    ##
    # Get the number of sensors available
    # for the current name (or the total number
    # of sensors available).
    def count() enum.count end # End count of sensors
    alias :count_s :count # Add alias for backwards compatibility
    
    # Protected methods
    protected
    
    ##
    # Validate a path -- protected
    def path_valid?(path)
      # Check that the path argument is a string
      if (!String === path) then
        STDERR.puts "::Sensor ERROR:: Path must be string!"
        return nil
      end # End check for correct path
      # Clean the path input
      dir = path.strip.gsub(/\/*$/, "")
      
      # Check if path is a directory, else exit early.
      # Do not need to check File.exist? first, b/c this
      # already returns nil, if it doesn't.
      if !File.directory?(dir) then
        STDERR.puts "::Sensors ERROR:: Path is either invalid or not a directory!"
        return nil
      end # End directory check
      dir # Return the correct path
    end # End path validation 
  end # End Sensors class
end # End LmSensors append