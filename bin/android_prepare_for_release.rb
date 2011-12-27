#!/usr/bin/ruby

require 'rubygems'
require 'optparse'
require 'ios_android_toolbox'
require 'ios_android_toolbox/ios'
require 'ios_android_toolbox/android'

include IosAndroidToolbox

version_file = VersionController.version_file
raise "Please specify the info.plist file" if version_file.nil?

raise "This script only works with Android projects" if (!is_android_project? and is_android_file? version_file)

ctrl = version_controller_for_version_file version_file

ctrl.set_debuggable(false)
ctrl.release_version

$output_file = version_file if $output_file == nil
ctrl.write_to_output_file($output_file)


