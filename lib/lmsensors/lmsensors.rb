# lib/lmsensors/lmsensors.rb

require_relative "../lmsensors_base/lmsensors_base"

module LmSensors
  ##
  # Wrap the module functions
  # 
  # Contains: ``pro_init``, ``pro_cleanup``
  def self.init(filename=nil) self.pro_init(filename) end
  def self.cleanup() self.pro_cleanup end
  
  ##
  # Sensors inherits the SensorsBase class
  # from the C side of the code. This abstracts
  # several features that were better-suited for
  # processing in a high-level language.
  class Sensors < LmSensors::SensorsBase
    attr_reader :chip_name
    
    ##
    # Constructor
    def initialize() pro_initialize end
      
    ##
    # Set the chip's name you want to
    # get -- by default, ``nil``, so it
    # will return ALL the chips
    def set_name(name) @chip_name = name end
        
    ##
    # Unset the current chip's name, so
    # it returns ALL the chips, again
    def unset_name() @chip_name = nil end
          
    ##
    # Return the currently-monitored chip's name
    def get_name() @chip_name end
            
    ##
    # Enumerate the chip and its features.
    # 
    # This will return a hash of either ALL
    # the available chips or the selected
    # chip set by ``set_name``.
    def enum(name=@chip_name) pro_enum(nil, @chip_name) end
              
    ##
    # Stat will return the values and names
    # of all the features associated with the
    # currently-selected chip.
    def stat() pro_enum(true, @chip_name) end
  end
end