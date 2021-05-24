# lib/lmsensors/lmsensors.rb

# Base requires
require_relative "../lmsensors_base/lmsensors_base"
require_relative "./lm_constants"
require_relative "./feature"

##
# LmSensors is the wrapping module for the entire
# lm-sensors library.
module LmSensors
  ##
  # Wrap the module functions
  # 
  # Contains: 'pro_init', 'pro_cleanup'
  def self.init(filename=nil) self.pro_init(filename) end
  def self.cleanup() self.pro_cleanup end
  
  ##
  # The fmap method maps the feature type to the
  # subclass that will be used to handle
  # formatting and analytic post-processing.
  def self.fmap(f_obj)
    case f_obj[:type]
    when SF_IN
      Feature::Voltage.new f_obj
    when SF_CURR
      Feature::Current.new f_obj
    when SF_POWER
      Feature::Power.new f_obj
    when SF_TEMP
      Feature::Temp.new f_obj
    when SF_FAN
      Feature::Fan.new f_obj
    when SF_INTRUSION
      Feature::Alarm.new f_obj
    when SF_BEEP_ENABLE
      Feature::Beep.new f_obj
    else
      Feature::GenFeature.new f_obj
    end
  end # End feature mapper
  
  ##
  # Sensors inherits the SensorsBase class
  # from the C side of the code. This abstracts
  # several features that were better-suited for
  # processing in a high-level language.
  class Sensors < LmSensors::SensorsBase
    attr_reader :chip_name, :filters, :subs
    
    ##
    # Constructor
    def initialize() 
      pro_initialize
      unset_filters
      @subs = false
    end
    
    ##
    # Set the chip's name you want to
    # get -- by default, 'nil', so it
    # will return ALL the chips
    def set_name(name) @chip_name = name end
    
    ##
    # Set the sensor's filters, the types that
    # will be returned on '.features'.
    def set_filters(arr)
      if Array === arr then
        @filters = arr.select { |item| LmSensors::UNITS.include? item } .sort
      else STDERR.puts "Filters must be an array" end
    end # End set filters
    
    ##
    # Unset the current chip's name, so
    # it returns ALL the chips, again
    def unset_name() @chip_name = nil end
     
    ##
    # Unset the filters for this sensor
    def unset_filters() @filters = [] end
    
    ##
    # Toggle whether this sensor also returns
    # subfeatures on a feature list request.
    def toggle_subs() @subs = !@subs end
    
    ##
    # Enumerate the chip and its features.
    # 
    # This will return a hash of either ALL
    # the available chips or the selected
    # chip set by 'set_name'.
    def enum(name=@chip_name) pro_enum(nil, name) end
    
    ##
    # Format a subfeature's output
    def fmt_sub(subf)
      subf.map do |key, val|
        unit = val[:unit]
        fmtv = case
          when Proc === unit
            unit.call(val[:value])
          when String === unit
            "#{val[:value]} #{unit}"
          else
            val[:value]
          end
        { key => val.merge({ fmt: fmtv }) }
      end.flatten
    end # End subfeature value formatter
    
    ##
    # Stat will return the values and names
    # of all the features associated with the
    # currently-selected chip.
    def stat(cnt=false)
      # If cnt flag is not set, drop the count from the stat
      pro_enum(true, @chip_name).then do |chips|
        cnt ? chips.update({count: chips.count}) : chips end
    end # End stat method
    
    ##
    # Find a device sensors by its path, in such
    # a case where the app already has a device from
    # sysfs or similar and needs to attach them together.
    # 
    # Sets the name of the sensor, as well, so this should
    # be used as an instance.
    def locate(path)
      # Clean the path input
      path = path.strip.gsub(/\/*$/, "")
      
      # Check if path is a directory, else exit early.
      # Do not need to check File.exist? first, b/c this
      # already returns nil, if it doesn't.
      if !File.directory?(path) then
        STDERR.puts "::Sensors ERROR:: Path is either invalid or not a directory!"
        return nil
      end # End directory check
      
      # Determine if it's a valid sensor, since the
      # sensors here use the path as the index.
      # If so, set it as this object's name
      enum.then do |sensors|
        # Return early, if it's not in the keys
        if !sensors.keys.include?(path) then
          STDERR.puts "Path does not have an associated sensor"
          return nil
        end # End check for valid sensor path
        
        # Set the name and return it
        set_name sensors[path][:name]
        @chip_name
      end # End enumeration handler
    end # End locate by path
    
    ##
    # Get the number of sensors available
    # for the current name (or the total number
    # of sensors available).
    def count_s() enum.count end # End count of sensors
    
    ##
    # Get the number of features available for
    # the current name (or total features to be
    # read for all sensors).
    def count_f
      total = 0 # Accumulator
      # Add up all the features
      stat.each { |_, v| total += v[:stat].count }
      total # Return accumulator
    end # End count of features
    
    ##
    # Get the number of subfeatures available for
    # the current name (or total features to be
    # read for all sensors).
    def count_sf
      total = 0 # Accumulator
      stat.each do |_, v|
        feats = v[:stat].collect do |_k, sv|
          # Ignore the :type symbol
          total += (sv.select { |item| :type != item } .count)
        end
      end
      total # Return accumulator
    end # End count of subfeatures
    
    ##
    # Return a list of features for all selected
    # chips. This replaces the old version, which
    # only accepted one chip, because it didn't
    # make sense and overcomplicated the process.
    # If only a single chip is desired, you will need
    # to filter it.
    def features
      # For each chip, split it by key and value
      stat.collect do |chip_key, data|
        fdata = if Hash === data then
          data[:stat].collect do |feature, keys|
            # Is the filter set?
            no_filter = @filters.empty?
            # Is the feature of a type included in the filter?
            included = @filters.include?(keys[:type])
            
            # If the filter is NOT set, OR the keys IS included
            # in the filter, proceed.
            if no_filter or included then
              # If the subfeature option is set, return
              # the subfeature data and the unit.
              if @subs then
                LmSensors.fmap(keys)
              # If the subfeature option is not set, just return
              # the feature type.
              else { feature => keys[:type] } end
            # If filtered and not included, return empty hash
            else {} end
          # Merge the feature hashes together
          end#.reduce Hash.new, :merge
        end
        # Create a chip to formatted feature hash
        { chip_key => fdata }
      # Merge them together as a path=>data hash
      end#.reduce Hash.new, :merge
    end # End features collector
  end # End Sensors object class
end # End LmSensors module