# lib/lmsensors.rb

##
# This global is set up, to handle ignoring of
# arity of passed procs for feature mapping.
$LmSensorsIgnArity = false

##
# This module is a C-Ruby wrapper for
# the program ``sensors``, which uses the
# library ``lmsensors``, on Linux.
require_relative "./lmsensors/lmsensors"
require_relative "./lmsensors/version"