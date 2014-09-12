#!/usr/bin/ruby


logfile = ARGV.shift


# This is here to force encoding so we don't have a problem with ASCII encoding, so accents aren't a problem
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

IO.foreach(logfile) do |line|
#     /usr/bin/codesign --force --sign "iPhone Developer: Igor Sales (N6726PC4QE)" --resource-rules=/Users/igorsales/Library/Developer/Xcode/DerivedData/FFSApp-bthsqocpmgfkvfcqpbhzyfofafmp/Build/Products/Adhoc-iphoneos/blacksheep.app/ResourceRules.plist --entitlements /Users/igorsales/Library/Developer/Xcode/DerivedData/FFSApp-bthsqocpmgfkvfcqpbhzyfofafmp/Build/Intermediates/FFSApp.build/Adhoc-iphoneos/___FFSApp___.build/blacksheep.xcent /Users/igorsales/Library/Developer/Xcode/DerivedData/FFSApp-bthsqocpmgfkvfcqpbhzyfofafmp/Build/Products/Adhoc-iphoneos/blacksheep.app
  #if /[\s[a-z\/]+codesign.*(?<!b)\s([^\s]+\.app)/.match line
  #if /^[\sa-z\/]+codesign.*\.xcent(\s|")([^\s]+\.app|".+\.app")/.match line
  if /CodeSign\s+"?(.+\.app)"?/.match line
    app_name = $1
    if not File.exist?(app_name)
        # Let's try another one, maybe it was archived
        symlink_app_name = app_name.gsub('/InstallationBuildProductsLocation/Applications/','/BuildProductsPath/Distribution-iphoneos/')
        if File.symlink?(symlink_app_name)
            xcode_archives_location = File.join(ENV['HOME'],'Library','Developer','Xcode','Archives')
	    	ctime = File.lstat(symlink_app_name).ctime
    		scheme_name = ''
    		if /\/Build\/Intermediates\/ArchiveIntermediates\/([^\/]+)/.match symlink_app_name
    			scheme_name = $1
    		end
    		app_basename = File.basename(symlink_app_name)

    		tries = 5
    		while (tries -= 1) > 0
	    		archive_date_folder = ctime.strftime('%Y-%m-%d')
	    		archive_folder_name = "#{scheme_name} #{ctime.strftime('%y-%m-%d')} #{ctime.hour % 12}.#{ctime.strftime('%M %p')}.xcarchive"

	    		dist_app_name = File.join(xcode_archives_location, 
	    			                      archive_date_folder, 
	    		    	                  archive_folder_name,
	    		        	              'Products', 
	    		            	          'Applications',
	    		                	      app_basename)

		    	# This might be a distribution one, let's check if it moved from
		    	# InstallationBuildProductsLocation/Applications => BuildProductsPath/Distribution-iphoneos
	    		if File.exist? dist_app_name
	    			app_name = dist_app_name
	    			tries = 0
	    		end

	    		ctime = ctime + 60
	    	end
	    end
    end
    puts app_name
  end
end
