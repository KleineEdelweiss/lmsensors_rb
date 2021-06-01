# frozen_string_literal: true
require_relative "lib/lmsensors/version.rb"

# Spec
Gem::Specification.new do |spec|
  spec.name = "lmsensors"
  spec.version = LmSensors::VERSION
  spec.summary = "Lmsensors wrapper in the C-Ruby API"
  spec.description = <<~DESC
    Wrapper for the ``lm-sensors`` library, which provides the programs, 
    ``sensors`` and ``sensors-detect``, for Linux systems. This library 
    and its programs are used to allow the user to access temperature and
    fan data for various hardware devices.
    
    The wrapper is written in the C-Ruby API, so you can use it in whatever 
    Ruby-based monitoring program makes the most sense and only using
    the parts relevant to your use case.
  DESC
  spec.authors = ["Edelweiss"]
  
  # Website data
  spec.homepage = "https://github.com/KleineEdelweiss/lmsensors_rb"
  spec.licenses = ["LGPL-3.0"]
  spec.metadata = {
    "homepage_uri"        => spec.homepage,
    "source_code_uri"     => "https://github.com/KleineEdelweiss/lmsensors_rb",
    #"documentation_uri"   => "",
    "changelog_uri"       => "https://github.com/KleineEdelweiss/lmsensors_rb/blob/master/CHANGELOG.md",
    "bug_tracker_uri"     => "https://github.com/KleineEdelweiss/lmsensors_rb/issues"
    }
  
  # List of files
  spec.files = Dir.glob("lib/**/*")
  
  # Rdoc options
  spec.extra_rdoc_files = Dir["README.md","CHANGELOG.md", "LICENSE.txt", "FMAPPER.md"]
  spec.rdoc_options += [
    "--title", "LmSensors -- Lmsensors wrapper in the C-Ruby API",
    "--main", "README.md",
    
    # Exclude task data from rdoc
    "--exclude", "Makefile",
    "--exclude", "Rakefile",
    "--exclude", "Gemfile",
    "--exclude", "lmsensors.gemspec",
    "--exclude", "rdoc.sh",
    
    # Other options
    "--line-numbers",
    "--inline-source",
    "--quiet"
  ]
  
  # Minimum Ruby version
  spec.required_ruby_version = ">= 2.7.0"
  
  # Compiled extensions
  spec.extensions = ['ext/lmsensors_base/extconf.rb']
end # End spec