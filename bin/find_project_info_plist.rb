#!/usr/bin/ruby

require 'rubygems'
require 'ios_android_toolbox/ios'
require 'ios_android_toolbox/android'

include IosAndroidToolbox

file = ARGV.shift

IosVersionController.find_project_info(file).each do |filename|
  puts filename
end

AndroidVersionController.find_project_info(file).each do |filename|
    puts filename
end
