#!/usr/bin/env ruby -wKU
# 110224, revised with loop to accept an array
# 110425, swapped order of variable definition in get_version


def get_version(apps)
  apps.each do |app|
   if File.exists?("#{app}/Contents/Info.plist")
     short = app.sub(/\/Applications\//, '')
     vers = `/usr/bin/defaults read "#{app}"/Contents/Info CFBundleShortVersionString`.chomp
     res = puts "#{short}: #{vers}"
     $?.success? ? res : "ERROR: could not get version"
   else
     puts "#{app} is not installed."
   end
 end
end


apps = ARGV
if ARGV.size == 0
  puts "no argument(s) passed, so let's loop through all apps under /Applications.\n\n"
  apps = Dir.glob("/Applications/*.app")
  get_version(apps)
else
  get_version(apps)
 end
