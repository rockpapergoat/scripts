#!/usr/bin/env ruby -wKU
# 110105, nate, initial draft of os x server config backup
#
# notes:
# cf. http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/205950
# cf. http://tinyurl.com/23ad2t4 (optparse syntax)
#
# original specs from moh:
# - SparseImage of their boot drive (minus user directories)
# - OD Archive (date in name)
# - Export of the OD Users (date in name)
# - Export of the OD Groups (date in name)

require 'optparse'

def date_stamp
  @date = Time.now.strftime("%y%m%d")
end

def set_destination
  @dest = "/var/bak"
end

def get_destination
  set_destination
  if File.exists?(@dest)
    puts "#{@dest} exists"
  else
    Dir.mkdir(@dest)
  end
end

# method sets up variables then backs up OD and passwd db
# get the password somehow or just set it explicitly (not secure)
def backup_od
  begin
  	puts "Be sure to note this for later use.\nPlease type a password for the OD backup:"
  	    system "stty -echo"
  	    @pass = $stdin.gets.chomp
  	    system "stty echo"
  	rescue NoMethodError, Interrupt
  	    system "stty echo"
    end
  mkpassdb = "/usr/sbin/mkpassdb"
  file = "/tmp/sacommands"
  commands=["dirserv:backupArchiveParams:archivePassword = #{@pass}", "dirserv:backupArchiveParams:archivePath = #{@dest}/odbackup-#{@date}", "dirserv:command = backupArchive"]
  sacommands = File.open("#{file}", "w") do |f|
    f.puts commands.each {|command| command}
  end
  system "/usr/sbin/serveradmin command < #{sacommands}"
  system "#{mkpassdb} -backupdb #{@dest}/mkpassdb-#{@date}"
  FileUtils.rm("#{sacommands}")
end


def export_users
  begin
    system "/usr/bin/dsexport #{@dest}/users_#{@date} /LDAPv3/127.0.0.1 Users --N"
  rescue Exception => e
  end
end

def export_groups
  begin
    system "/usr/bin/dsexport #{@dest}/groups_#{@date} /LDAPv3/127.0.0.1 Groups --N"
  rescue Exception => e
  end
end

def import_users(importfile)
  puts "#{current_method} is not implemented yet."
end

def import_groups(importfile)
  puts "#{current_method} is not implemented yet."
end

def backup_services
  begin
    system "/usr/sbin/serveradmin list".each do |service|
      system "/usr/sbin/serveradmin settings #{service} > #{@dest}/#{service}_#{@date}"
    end
  rescue Exception => e
  end 
end

def import_services(*args)
  puts "#{current_method} is not implemented yet."
end

# checks

def current_method
  caller[0] =~ /`([^']*)'/ and $1
end

def check_root
  if ENV['USER'] != "root"
    puts "This script must be run as root.\nPlease try again."
    exit(1)
  end
end




# call methods to set instance variables
date_stamp
get_destination

# are we root?
check_root
backup_od
export_users
export_groups

exit(0)