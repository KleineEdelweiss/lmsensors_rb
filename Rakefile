# Rakefile
require "rake/extensiontask"

# Build the LmSensors extension
Rake::ExtensionTask.new "lmsensors_base" do |ext|
  ext.lib_dir = "lib/lmsensors_base"
  ext.source_pattern = "*.{c,h}"
end # End build on LmSensors