# ext/lmsensors_base/extconf.rb
require 'mkmf'

# Build LmSensors
$LFLAGS = '-lsensors'
$FLAGS = 'clean'
have_library("sensors")
have_header("sensors/sensors.h")
create_makefile("lmsensors_base")