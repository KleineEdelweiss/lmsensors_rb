### OVERVIEW ###
LmSensors is a C-Ruby API wrapper for ``lmsensors`` (which runs the ``sensors`` and ``sensors-detect`` commands) on Linux systems. This will allow users to access temperature, fan, and bus data for various system hardware devices.

### USAGE ###
```ruby
LmSensors.init # Initialize the Sensors system data
LmSensors.cleanup # Cleanup the Sensors data, when done

# Create a new sensor spawner/bag
# ``.enum`` and ``.stat`` default to ALL sensors, unless
# a name is set with ``.set_name``
s = LmSensors::SensorSpawner.new
# LmSensors::Sensors is now just an alias of SensorSpawner.
# I left this for compatibility purposes.

# Count the number of sensors detected by the spawner,
# with the current settings. Also works with a concrete
# Sensor object, but will return the number of features.
s.count # or s.count_s

# Assign a list of all the selected sensors available
# ``.enum`` will return a list of LmSensors::AbsSensor objects
# or their subclasses.
items = s.enum

# Where :idx is an int in range, assign new
# AbsSensor object to sobj.
sobj = items[:idx] 
sobj.stat # Stat the selected sensor, getting raw output
sobj.features # Return the features on a sensor
sobj.count_sf # Return the number of subfeatures on a Sensor object

# Set the name of the desired sensors to collect
# Can be set to either specific sensor or a wildcard.
# 
# This will return a list of AbsSensors of the type.
# 
# Example: "amdgpu-*", for ANY Radeon card using this driver
# Example: "*-pci-*", for ANY device on the PCI bus
# Example: "k10temp-pci-00c3", for a Ryzen or other k10temp CPU
#             identified on the PCI bus, with the identifier, '00c3'
#             (This is from my dev system, so yours might be different)
s.set_name :name
s.name # Return the current chip or collector's name
s.unset_name # Unset the chip selection -- ``.enum`` will go back to ALL chips

# Set the filters to return for a Sensor.
# The selected features must be an array.
# For convenience, the features may use the
# constants from the class.
# 
# Example: [1,2], for ONLY fans and temps
# Example: [SF_FAN, SF_POWER], for ONLY fans and power
sobj.set_filters :arr_of_choices
sobj.unset_filters # Unset the filters -- returns ALL

# Toggle whether to receive the subfeatures or
# only to receive the features with their type.
sobj.toggle_subs

# Assign the features from a Sensor.
# This will return an array of Feature objects.
fs = sobj.features

# Format the feature data. Some types will have a pre-defined
# format, but for others, you can derive LmSensors::Feature::GenFeature.
fs[0].fmt # Will format the first feature returned.

# This will return the feature type and name.
# 
# Example: { :name => :vddgfx, :type => 0 }, for the voltage on my GPU
#   :vddgfx is the name
#   :type => 0, refers to the fact that this feature is measured with
#     the voltage type (SF_IN, Voltage, 0).
fs[0].feature
```

### TO-DO ###
1) A lot more cleaning than originally anticipated
1) ~~Finish several~~ _MINIMIZE_ subclasses of the GenFeature type[, as they largely only need to override the format method]
1) Remove some default formatting functions and attach them directly to the subclasses
1) Add in some more simplifying methods for formatting and calculations
1) Write up the rest of the documentation
1) Publish version 0.1.0

### INSTALLATION ###
This wrapper requires the header files for ``lmsensors`` to be installed. For some systems, it will come with the userspace package directly. For others, it is a separate package. The header required is ``sensors.h``.

NOTE: Below is how you can install it on various distros. As I use Arch and Debian, I had to look up the others, so if there is an issue, please submit the correction, and I will fix it.

Arch:
```
sudo pacman -S lm_sensors
```
Debian-like (Debian, Ubuntu, Mint):
```
sudo apt install lm-sensors libsensors-dev
```
Fedora-like:
```
sudo yum install lm_sensors lm_sensors-devel
sudo dnf install lm_sensors lm_sensors-devel
```
Gentoo:
```
sudo emerge --ask sys-apps/lm_sensors
```
For OpenSUSE, you will need to find a package that provides ``sensors.h``
https://www.mankier.com/8/zypper.
However, it appears that the correct way to install it will be:
```
sudo zypper install libsensors4-devel
```

Then, you can install it for Ruby:
```
gem install lmsensors
```