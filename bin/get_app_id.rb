#!/usr/bin/ruby

require 'rubygems'
require 'optparse'
require 'ios_android_toolbox'
require 'ios_android_toolbox'

include IosAndroidToolbox

version_file = VersionController.version_file
raise "Please specify the version file" if version_file.nil?

ctrl = version_controller_for_version_file version_file

puts ctrl.app_id


