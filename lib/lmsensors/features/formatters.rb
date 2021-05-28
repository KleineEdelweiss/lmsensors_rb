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
    # Base formatting for anything else
    BASE_FMT = lambda do |feature|
      feature.subfs.collect do |sfk, sfv|
        # Do not include single-item keys
        if Hash === sfv then
          # Attach the unit type to the subfeature
          { sfk => sfv.merge({ unit: LmSensors::UNITS[feature.type] }) }
        end
      # Remove empties, merge the subfeature hashes together
      end.compact.reduce Hash.new, :merge
    end # End base formatter proc
    
    ##
    # Default fan formatting proc
    FMT_FAN = lambda do |feature|
      feature.subfs.map do |key, val|
        # Format all the other subtypes
        stype = val[:subtype]
        skey = feature.class::FORMAT[stype]
        if skey then
          feature.fstruct[skey] = val[:value] end
        feature.fstruct[key] = "#{val[:value].round} #{feature.ftype}"
      end # End mapping loop
      # Format the outputs
      feature.fstruct[:input_fmt] = "#{feature.fstruct[:input].round} #{feature.ftype}"
      feature.fstruct[:min_fmt] = "#{feature.fstruct[:min].round} #{feature.ftype}"
      feature.fstruct[:max_fmt] = "#{feature.fstruct[:max].round} #{feature.ftype}"
      
      # Format the usage percent
      perc = ((feature.fstruct[:input].to_f / feature.fstruct[:max]) * 100).round(2)
      feature.fstruct[:usage] = "#{perc}%"
      feature.fstruct
    end # End default fan formatter
  end # End wrap in Feature
end # End wrap in LmSensors