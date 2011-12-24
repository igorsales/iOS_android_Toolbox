#!/usr/bin/ruby

require 'rubygems'
require 'optparse'
require 'ios_android_toolbox/ios'
require 'ios_android_toolbox/android'

include IosAndroidToolbox

version_file = ARGV.shift
if version_file.nil?
    files = IosVersionController.find_project_info << AndroidVersionController.find_project_info
    files.flatten!
    
    version_file = files.first if files.length == 1
end
raise "Please specify the version file" if version_file.nil?

ctrl = nil
if is_ios_filename? version_file
    ctrl = IosVersionController.new(version_file)
elsif is_android_filename? version_file
    ctrl = AndroidVersionController.new(version_file)
else
    raise "Unrecognizable project type for file #{version_file}"
end

puts ctrl.version


