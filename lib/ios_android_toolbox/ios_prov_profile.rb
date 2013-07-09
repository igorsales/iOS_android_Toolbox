require 'rubygems'
require 'fileutils'
require 'time'
require 'plist'

module IosAndroidToolbox
	class IosProvisioningProfile
		PROV_PROFILE_DIR=ENV['HOME']+'/Library/MobileDevice/Provisioning Profiles'
		UUID_REGEX='[0-9A-Za-z]{8}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{12}'

		DEBUG=false

		attr_reader :contents

		def plist_string
			@plist_string ||= begin
				xml_start = contents.index('<?xml version=')
				return nil if xml_start.nil?

				xml_end = contents.index('</plist>', xml_start)
				return nil if xml_end.nil?

				contents.slice(xml_start, xml_end - xml_start + 8)
			end
		end

		def plist
			plist ||= Plist.parse_xml(plist_string)
		end

		def uuid
		  # <key>UUID</key>
		  #  <string>06AF2826-608D-4CE9-99AE-AA917FF1641E</string>
		  if /<key>UUID<\/key>\s*<string>(#{UUID_REGEX})<\/string>/.match(contents)
		    puts "Found UUID: #{$1}" if DEBUG
		    uuid = $1
		  else
		    nil
		  end
		end

		def path
			File.join(PROV_PROFILE_DIR,uuid+".mobileprovision")
		end

		def app_id
			@app_id ||= begin
				id = plist['Entitlements']['application-identifier']
				id.gsub(/^[A-Z0-9]+\./,'')
			end
		end

		def app_id_name
			plist['AppIDName']
		end

		def app_id_prefix
			plist['ApplicationIdentifierPrefix']
		end

		def creation_date
			plist['CreationDate']
		end

		def has_provisioned_devices?
		  # <key>ProvisionedDevices</key>
		  !!(/<key>ProvisionedDevices<\/key>/.match(contents))
		end

		def provisioned_devices
			plist['ProvisionedDevices']
		end

		def aps_environment
			plist['Entitlements']['aps-environment']
		end

		def get_task_allow
			plist['Entitlements']['get-task-allow']
		end

		def is_development?
			provisioned_devices.is_a? Array and get_task_allow == true
		end

		def is_production?
			provisioned_devices.nil? and get_task_allow == false
		end

		def is_adhoc?
			provisioned_devices.is_a? Array and get_task_allow == false
		end

		def is_development_aps_environment?
			aps_environment == 'development'
		end

		def is_production_aps_environment?
			aps_environment == 'production'
		end

		def initialize(contents)
			# If we specify a path, read it first
			begin
				if File.exists? contents and not File.directory? contents
					contents = File.open(contents).read
				end
			rescue
			end
			@contents = contents
		end

		def self.remove_stale_equivalent_profiles(path)
			new_profile = IosProvisioningProfile.new(path)

  			self.loop_through_existing_profiles do |installed_profile, installed_profile_path|
  				if installed_profile.app_id == new_profile.app_id and 
	 			   installed_profile.creation_date < new_profile.creation_date and 
	 			   installed_profile.has_provisioned_devices? == new_profile.has_provisioned_devices?
					puts "Removing stale Prov Profile: #{installed_profile_path}"
    				File.delete installed_profile_path
  				end
			end
		end

		def self.install(path)
			if not File.directory? PROV_PROFILE_DIR
				FileUtils.mkdir_p PROV_PROFILE_DIR
				FileUtils.chmod 0755, PROV_PROFILE_DIR
			end

			new_profile = IosProvisioningProfile.new(path)
			new_path    = File.join(PROV_PROFILE_DIR, new_profile.uuid+".mobileprovision")

			if File.expand_path(path) != File.expand_path(new_path)
				if profile_worth_installing? path
					self.remove_stale_equivalent_profiles(path)
					FileUtils.copy(path, new_path)
				end
			else
				puts "Cannot install new profile over itself!"
			end
		end

		def self.profile_worth_installing?(path)
			new_profile = IosProvisioningProfile.new(path)
			loop_through_existing_profiles do |installed_profile, path|
  				if installed_profile.app_id == new_profile.app_id and installed_profile.has_provisioned_devices? == new_profile.has_provisioned_devices?
	 			  	return false if installed_profile.creation_date >= new_profile.creation_date 
  				end
			end

			true
		end

		def self.loop_through_profiles_for_app_id(id, &block)
			self.loop_through_existing_profiles do |p,path|
				yield p if p.app_id == id
			end
		end

		private
		def self.loop_through_existing_profiles(&block)
			# Look through each file in the list
			Dir.glob(File.join(PROV_PROFILE_DIR,"*.mobileprovision")) do |installed_profile_path|
  
				next if not /#{UUID_REGEX}\.mobileprovision$/.match(installed_profile_path)
  				puts "Examining prov. profile: #{installed_profile_path}" if DEBUG

  				installed_profile = IosProvisioningProfile.new(File.open(installed_profile_path).read)

  				yield installed_profile, installed_profile_path
			end
		end
	end
end