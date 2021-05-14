# ext/lmsensors/extconf.rb
require 'mkmf'

# Build LmSensors
$LFLAGS = '-lsensors'
have_library("sensors")
have_header("sensors/sensors.h")
create_makefile("lmsensors/lmsensors")