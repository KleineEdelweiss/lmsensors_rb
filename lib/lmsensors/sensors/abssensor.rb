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
    # Alias :name to :chip_name
    alias :name :chip_name
    
    ##
    # Constructor
    def initialize
      pro_initialize
      unset_filters
      @subs = false
    end # End constructor
    
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
  end # End Sensors class
end # End LmSensors append