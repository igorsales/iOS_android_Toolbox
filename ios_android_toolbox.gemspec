# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ios_android_toolbox/version"

Gem::Specification.new do |s|
  s.name        = "ios_android_toolbox"
  s.version     = IosAndroidToolbox::VERSION
  s.authors     = ["Igor Sales"]
  s.email       = ["self@igorsales.ca"]
  s.homepage    = ""
  s.summary     = %q{Toolbox to manipulate iOS/Android projects}
  s.description = %q{}

  s.rubyforge_project = "ios_android_toolbox"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
