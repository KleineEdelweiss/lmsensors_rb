# lib/lmsensors/features/formatters.rb

##
# This module contains several default format procs
# that can be passed to the various Feature types.
# 
# If your use case requires a different format, you can
# pass a proc of your own. The purpose of providing these
# base formatting functions is to offer some default options
# that most people should find useful.
module LmSensors
  # Wrap the procs in the Feature submodule
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
    # Default formatting proc for
    # the X_FAN subtype.
    FMT_FAN = lambda do |feature|
      puts "Fan formatter"
      # Formatted structure
      unit = feature.unit
      out = { name: feature.name, type: feature.type, unit: unit }
      tmp = { input: nil, max: nil }
      
      # Format the outputs
      # Strip each, in case the unit is empty
      feature.subfs.values.map do |v|
        case v[:subtype]
        when SSF_FAN_INPUT
          tmp[:input] = v[:value]
          out[:input] = "#{v[:value]} #{unit}".strip
        when SSF_FAN_MAX
          tmp[:max] = v[:value]
          out[:max] = "#{v[:value]} #{unit}".strip
        when SSF_FAN_MIN
          out[:min] = "#{v[:value]} #{unit}".strip
        end
      end # End value mapper for fan
      
      # Calculate the percentage of max speed of fan
      if tmp[:max] and tmp[:input] then
        perc = ((tmp[:input].to_f / tmp[:max]) * 100).round(2)
        out[:percent] = "#{perc}%".strip
      end # Only if both are present
      out
    end # End default fan formatter
  end # End wrap in Feature
end # End wrap in LmSensors