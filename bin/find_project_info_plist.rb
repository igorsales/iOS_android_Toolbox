#!/usr/bin/ruby

require 'rubygems'
require 'plist'

VersionKey='CFBundleVersion'

candidates = []

plists=`find . -name "*.plist"`

plists.split("\n").each do |filename|
  if File.exists?(filename)
    begin
      dict = Plist.parse_xml(filename)
      candidates.push filename if dict and dict[VersionKey]
    rescue
      # Do nothing, just skip the file. Must be in binary format
    end
  end
end

max_components = 9999
candidates.each do |filename|
  components = filename.split(File::SEPARATOR)
  if components.length < max_components
    max_components = components.length
  end
end

candidates = candidates.find_all { |filename| filename.split(File::SEPARATOR).length == max_components }

candidates.each do |filename|
  puts filename
end
