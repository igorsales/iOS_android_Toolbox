require 'fileutils'
require 'time'

module IosAndroidToolbox
	class IosProvisioningProfile
		PROV_PROFILE_DIR=ENV['HOME']+'/Library/MobileDevice/Provisioning Profiles'
		UUID_REGEX='[0-9A-Za-z]{8}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{4}-[0-9A-Za-z]{12}'

		DEBUG=false

		attr_reader :contents

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

		def app_id
		  # <key>application-identifier</key>
		  # <string>NDVAA33T9J.com.favequest.FFSApp.87.ircpa</string>
		  if /<key>application-identifier<\/key>\s*<string>[A-Za-z0-9]+\.([^<]+)<\/string>/.match(contents)
		    puts "Found app Id: #{$1}" if DEBUG
		    app_id = $1
		  else
		    nil
		  end
		end

		def creation_date
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

		def has_provisioned_devices?
		  # <key>ProvisionedDevices</key>
		  /<key>ProvisionedDevices<\/key>/.match(contents)
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

			# Look through each file in the list
			# Dir.glob(File.join(PROV_PROFILE_DIR,"*.mobileprovision")) do |installed_profile_path|
  
			# 	next if not /#{UUID_REGEX}\.mobileprovision$/.match(installed_profile_path)
  	# 			puts "Examining prov. profile: #{installed_profile_path}" if DEBUG

  	# 			installed_profile = IosProvisioningProfile.new(File.open(installed_profile_path).read)

  			self.loop_through_existing_profiles do |installed_profile|
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
			loop_through_existing_profiles do |installed_profile|
  				if installed_profile.app_id == new_profile.app_id
	 			  	return false if installed_profile.creation_date >= new_profile.creation_date 
  				end
			end

			true
		end

		private
		def self.loop_through_existing_profiles(&block)
			# Look through each file in the list
			Dir.glob(File.join(PROV_PROFILE_DIR,"*.mobileprovision")) do |installed_profile_path|
  
				next if not /#{UUID_REGEX}\.mobileprovision$/.match(installed_profile_path)
  				puts "Examining prov. profile: #{installed_profile_path}" if DEBUG

  				installed_profile = IosProvisioningProfile.new(File.open(installed_profile_path).read)

  				yield installed_profile
			end
		end
	end
end