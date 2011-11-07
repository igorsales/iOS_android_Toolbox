#!/usr/bin/ruby

require 'rubygems'
require 'plist'
require 'optparse'

VERSION_KEY = 'CFBundleVersion'

inc_idx = 3
max_comps = 4
output_file = nil

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: inc_version.rb [options] <info.plist>"
              
  opts.on("-M", "--major", "Increments MAJOR number") do |v|
    inc_idx = 0
    max_comps = 3
  end
  opts.on("-m", "--minor", "Increments MINOR number") do |v|
    inc_idx = 1
    max_comps = 3
  end
  opts.on("-s", "--subminor", "Increments SUBMINOR number") do |v|
    inc_idx = 2
    max_comps = 3
  end
  opts.on("-rc", "--candidate", "Increments RELEASE CANDIDATE number (default option)") do |v|
    inc_idx = 3
    max_comps = 4
  end
  opts.on("-o", "--output file", "Direction output to file") do |v|
    output_file = v
  end
end.parse!

version_file = ARGV.shift
raise "Please specify the info.plist file" if version_file.nil?

dict = Plist.parse_xml(version_file)
version = dict[VERSION_KEY]

exit 1 if version.nil?

components = version.split('.')

should_inc_prev_idx = (inc_idx > 0 and components[inc_idx].nil?)

while components.length < inc_idx
  components.push 0
end

if components.length > inc_idx
  inc_comp = components[inc_idx].to_i
else
  inc_comp = -1
end

inc_comp += 1
components[inc_idx] = inc_comp
components.each_index do |i|
  components[i] = 0 if i > inc_idx
end

if should_inc_prev_idx
  components[inc_idx-1] = components[inc_idx-1].to_i+1
end

components = components.slice(0,max_comps)

version = components.join "."

dict[VERSION_KEY] = version

output_file = version_file if output_file == nil

if output_file == '-'
  puts dict.to_plist
else
  dict.save_plist output_file
end
