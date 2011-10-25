#!/usr/bin/ruby
# 110603, nate@tsp, first version

# use this to import mcx for all local users

require 'FileUtils'


# find local users and exclude system and admin accounts
def get_users
  @users = `dscl . -list /users`.split("\n").reject { |user| user.match(/^_/) or ["root","puppet","daemon", "Guest", "nobody", "casper"].include?(user) }
end

# test whether mcx files are available first.
# if not, don't run any imports and quit.
def get_mcx
  folder = "/etc/mcx"
  if File::directory?("#{folder}")
    @files = Dir.glob("#{folder}/*.plist")
    p @files
    if @files == []
      puts "no mcx files to import. quitting now."
      exit(1)
    end
  else
    FileUtils.mkdir_p("#{folder}", :verbose => true)
    FileUtils.chown_R("root", "staff", "#{folder}", :verbose => true)
    @files = Dir.glob("#{folder}/*.plist")
    p @files
    if @files == []
      puts "no mcx files to import. quitting now."
      exit(1)
    end
  end
end

# import mcx for local users
def mcx_import
  users = get_users
  prefs = get_mcx
  users.each do |u|
    prefs.each do |mcx|
      puts "importing #{mcx} for #{u}..."
      %x(/usr/bin/dscl . -mcximport /Users/#{u} #{mcx})
    end
  end
end

mcx_import