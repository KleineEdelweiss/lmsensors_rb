### OVERVIEW ###
LmSensors is a C-Ruby API wrapper for ``lmsensors`` (which runs the ``sensors`` and ``sensors-detect`` commands) on Linux systems. This will allow users to access temperature, fan, and bus data for various system hardware devices.

### USAGE ###
```ruby
# Global value only relevant to overriding format-mapping
# functions. This is 'false', by default, but when set to
# 'true', it disables a warning about the arity passed to
# the format-mapping method of the abstract GenSensor, as
# this class cannot guarantee knowing subclasses.
$LmSensorsIgnArity

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

# Locate a specific Sensor on a SensorSpawner. This is
# a shorthand way to assign a specific sensor, quickly, if you
# already know the path, such as what might have been returned
# from another gem or script.
s.locate :path # Where path is something like '/sys/class/hwmon/hwmon3'

# Assign a list of all the selected sensors available
# ``.enum`` will return a list of LmSensors::AbsSensor objects
# or their subclasses.
items = s.enum

# Sets the fmap of the sensor. If this is set on a SensorSpawner,
# it will automatically use the same format map for any sensors it
# creates. If it is set on a single Sensor, it will only affect that
# one. This method can be used to pass in a custom Proc/Lambda
# object for the sensor in question to use as its feature-formatting
# selector. By default, the format will be 'LmSensors::DEF_FMAP'.
# 
# For more details on this, please view 'FMAPPER.md'
s.set_fmap :your_proc

s.reset_fmap # Reset it back to the default

# Where :idx is an int in range, assign new
# Sensor object to sobj.
sobj = items[:idx]
sobj.name # Name of Sensor
sobj.adapter # Adapter of Sensor
sobj.path # Path of Sensor
sobj.info # Return the name, adapter, and path of a Sensor
sobj.read # Raw data from the :stat part of the Sensor
sobj.stat # Stat the selected sensor, returning features
sobj.features # Alias for :stat
sobj.count # Count the number of features
sobj.count_s # Alias for :count
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
# Example: [LmSensors::SF_FAN, LmSensors::SF_POWER], for ONLY fans and power
sobj.set_filters :arr_of_choices
sobj.unset_filters # Unset the filters -- returns ALL

# Toggle whether to receive the subfeatures or
# only to receive the features with their type.
# By default, this is false, and you will receive the
# type only.
sobj.toggle_subs

# Toggle whether to format output. By default, this is false.
# When false, it returns the raw state of the feature object.
sobj.toggle_fmt

# Assign the features from a Sensor.
# This will return an array of Feature objects.
fs = sobj.features # This is an alias for :stat

# Format the feature data. Some types will have a pre-defined
# format, but for others, you can derive LmSensors::Feature::GenFeature.
# 
# This method can also take a separate formatter. The default is
# 'LmSensors::Feature::BASE_FMT', which returns it as a simple hash.
fs[0].fmt # Will format the first feature returned.

# This will return the feature type and name.
# 
# Example: { :name => :vddgfx, :type => 0 }, for the voltage on my GPU
#   :vddgfx is the name
#   :type => 0, refers to the fact that this feature is measured with
#     the voltage type (LmSensors::SF_IN, Voltage, 0).
fs[0].feature
```

### TO-DO ###
~~1) DONE, FINALLY!~~

### INSTALLATION ###
_DEV LIBS: As this is an extension, you will require the Ruby development headers. On some systems, this will come packaged with your Ruby installation. On others, you may need to install additional packages, such as ``ruby-dev`` (Ubuntu and similar). Check your specific system's requirements, and make sure you have the headers, as well as RubyGems and Rdoc_

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