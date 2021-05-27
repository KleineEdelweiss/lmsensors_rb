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
    attr_reader :chip_name, :filters, :subs
    
    ##
    # Constructor
    def initialize
      pro_initialize
      unset_filters
      @subs = false
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
      else STDERR.puts "Filters must be an array" end
    end # End set filters
    
    ##
    # Unset the filters for this sensor
    def unset_filters() @filters = [] end
    
    ##
    # Toggle whether this sensor also returns
    # subfeatures on a feature list request.
    def toggle_subs() @subs = !@subs end
    
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