#!/usr/bin/ruby

require 'rubygems'
require 'ios_android_toolbox/ios'

include IosAndroidToolbox

prev = ARGV.shift
replace = ARGV.shift

if prev.nil? and replace.nil?
  puts "Usage: ios_replace_url_scheme [prev] replace"
  exit
end

if replace.nil?
  replace = prev
  prev = nil
end

version_file = VersionController.version_file

ctrl = version_controller_for_version_file version_file

schemes = ctrl.url_schemes

exit if schemes.empty?

if prev.nil?
  prev = schemes[0]
else
  regex = Regexp.new(prev)
  prevs = schemes.select do |scheme|
    regex.match(scheme)
  end

  if prevs.length > 0
    prev = prevs[0]
  else
    prev = nil
  end
end

ctrl.replace_url_scheme(prev, replace)
ctrl.write_to_plist_file(version_file)
