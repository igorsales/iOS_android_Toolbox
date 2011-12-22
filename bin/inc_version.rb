#!/usr/bin/ruby

require 'rubygems'
require 'plist'
require 'optparse'
require 'ios_android_toolbox/ios'

include IosAndroidToolbox

$inc_idx   = 4
$max_comps = 4

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: inc_version.rb [options] <info.plist>"
              
  opts.on("-M", "--major", "Increments MAJOR number") do |v|
    $inc_idx = 0
    $max_comps = 3
  end
  opts.on("-m", "--minor", "Increments MINOR number") do |v|
    $inc_idx = 1
    $max_comps = 3
  end
  opts.on("-s", "--subminor", "Increments SUBMINOR number") do |v|
    $inc_idx = 2
    $max_comps = 3
  end
  opts.on("-rc", "--candidate", "Increments RELEASE CANDIDATE number (default option)") do |v|
    $inc_idx = 3
    $max_comps = 4
  end
  opts.on("-o", "--output file", "Direction output to file") do |v|
    $output_file = v
  end
end.parse!

version_file = ARGV.shift
raise "Please specify the info.plist file" if version_file.nil?

ctrl = IosVersionController.new(version_file)

ctrl.inc_idx   = $inc_idx
ctrl.max_comps = $max_comps
ctrl.next_version!

$output_file = version_file if $output_file == nil
ctrl.write_to_plist_file($output_file)


