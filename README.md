### OVERVIEW ###
LmSensors is a C-Ruby API wrapper for ``lmsensors`` (which runs the ``sensors`` and ``sensors-detect`` commands) on Linux systems. This will allow users to access temperature, fan, and bus data for various system hardware devices.

### USAGE ###
```ruby
LmSensors.init # Initialize the Sensors system data
LmSensors.cleanup # Cleanup the Sensors data, when done
s = LmSensors::Sensors.new # Create a new sensor
# ``.enum`` and ``.stat`` default to ALL sensors, unless
# a name is set with ``.set_name``
s.enum # Get a list of all the selected sensors available
s.stat # Stat the selected sensors

# Set the name of the desired sensor to monitor
# Can be set to either specific sensor or a wildcard
# Example: "amdgpu-*", for ANY Radeon card using this driver
# Example: "*-pci-*", for ANY device on the PCI bus
# Example: "k10temp-pci-00c3", for a Ryzen or other k10temp CPU
#             identified on the PCI bus, with the identifier, '00c3'
#             (This is from my dev system, so yours might be different)
s.set_name :name

# Unset the chip selection -- ``.enum`` and ``.stat`` will go back to ALL chips
s.unset_name
s.get_name # Return the current chip selection's name
```

### TO-DO ###
1) Clean up the code and directory tree
1) See about adding formatting for values, based on the ``SENSORS_FEATURE_TYPE`` and/or ``SENSORS_SUBFEATURE_TYPE`` (on either the C or Ruby side)
1) Write up the rest of the documentation
1) Publish version 0.1.0

### INSTALLATION ###
```
gem install lmsensors
```