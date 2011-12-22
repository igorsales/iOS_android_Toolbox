#!/usr/bin/ruby


logfile = ARGV.shift

IO.foreach(logfile) do |line|
#     /usr/bin/codesign --force --sign "iPhone Developer: Igor Sales (N6726PC4QE)" --resource-rules=/Users/igorsales/Library/Developer/Xcode/DerivedData/FFSApp-bthsqocpmgfkvfcqpbhzyfofafmp/Build/Products/Adhoc-iphoneos/blacksheep.app/ResourceRules.plist --entitlements /Users/igorsales/Library/Developer/Xcode/DerivedData/FFSApp-bthsqocpmgfkvfcqpbhzyfofafmp/Build/Intermediates/FFSApp.build/Adhoc-iphoneos/___FFSApp___.build/blacksheep.xcent /Users/igorsales/Library/Developer/Xcode/DerivedData/FFSApp-bthsqocpmgfkvfcqpbhzyfofafmp/Build/Products/Adhoc-iphoneos/blacksheep.app
  #if /[\s[a-z\/]+codesign.*(?<!b)\s([^\s]+\.app)/.match line
  #if /^[\sa-z\/]+codesign.*\.xcent(\s|")([^\s]+\.app|".+\.app")/.match line
  if /CodeSign\s+"?(.+\.app)"?/.match line
    app_name = $1
    puts app_name
  end
end
