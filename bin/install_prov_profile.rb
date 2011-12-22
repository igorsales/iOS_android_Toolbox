#!/usr/bin/ruby

require 'rubygems'
require 'parsedate'

DEBUG=false
PROV_PROFILE_DIR=ENV['HOME']+'/Library/MobileDevice/Provisioning Profiles'
UUID_REGEX='[0-9A-Za-z]{8}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{12}'

profile_file = ARGV.shift
profile_file or raise "Please specify a provisioning profile name"

prov_profile = File.open(profile_file).read

def uuid_for_profile(contents)
  # <key>UUID</key>
  #  <string>06AF2826-608D-4CE9-99AE-AA917FF1641E</string>
  if /<key>UUID<\/key>\s*<string>(#{UUID_REGEX})<\/string>/.match(contents)
    puts "Found UUID: #{$1}" if DEBUG
    uuid = $1
  else
    nil
  end
end

def app_id_from_profile(contents)
  # <key>application-identifier</key>
  # <string>NDVAA33T9J.com.favequest.FFSApp.87.ircpa</string>
  if /<key>application-identifier<\/key>\s*<string>[A-Za-z0-9]+\.([^<]+)<\/string>/.match(contents)
    puts "Found app Id: #{$1}" if DEBUG
    app_id = $1
  else
    nil
  end
end

def creation_date_from_profile(contents)
  # <key>CreationDate</key>
  # <date>2011-08-30T02:11:55Z</date>
  if /<key>CreationDate<\/key>\s*<date>([^<]+)<\/date>/.match(contents)
    #creation_date = Date.strptime($1, '%Y-%m-%dT%h:%M:%sZ')
    creation_date = Time.parse($1)
    puts "Found Creation date: #{creation_date.to_s}" if DEBUG
    creation_date
  else
    nil
  end
end

new_uuid   = uuid_for_profile(prov_profile)
new_app_id = app_id_from_profile(prov_profile)
new_cdate  = creation_date_from_profile(prov_profile)

# Look through each file in the list
Dir.foreach(PROV_PROFILE_DIR) do |item|
  next if item == '.' or item == '..'

  next if !/#{UUID_REGEX}\.mobileprovision/.match(item)
  puts "Prov. profile: #{item}" if DEBUG

  old_prov_profile = File.open(PROV_PROFILE_DIR+"/"+item).read

  old_uuid   = uuid_for_profile(old_prov_profile)
  old_app_id = app_id_from_profile(old_prov_profile)
  old_cdate  = creation_date_from_profile(old_prov_profile)

  if old_app_id == new_app_id and old_cdate < new_cdate
    puts "Removing stale Prov Profile: #{item}"
    File.unlink PROV_PROFILE_DIR+'/'+item
  end
end

new_profile_path = PROV_PROFILE_DIR+"/#{new_uuid}.mobileprovision"
puts "Installing new prov profile into #{new_profile_path}"
`cp -f "#{profile_file}" "#{new_profile_path}"`
