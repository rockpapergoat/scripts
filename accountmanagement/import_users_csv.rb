#!/usr/bin/env ruby -wKU
# 100926, nate, initial version and testing
# 101208, *** be sure to change afp and nfs paths below in create_users method
# modified to accommodate more csv fields
# cf. http://snippets.dzone.com/posts/show/3899
# cf. http://dmathieu.com/en/ruby/ruby-console-ask-for-a-password (basically standard shell method of using stty)

###
# NOTE:
# csv format i'm using is the following:
# shortname,firstname,lastname,uid,guid,nfshomedir,homedir,keyword,realname
# if you have fewer or more, etc., adjust accordingly
###

require 'csv'

def read_csv(data)
  csv_data = CSV.read(data)
  string_data = csv_data.map {|row| row.map {|cell| cell.to_s}}
  #headers = csv_data.shift.map {|i| i.to_s }
  #array_of_hashes = string_data.map {|row| Hash[*headers.zip(row).flatten] }
end


#def construct_uid(year)
#  source = read_csv(file)
#  # this produces uids formatted like 2013099
#  # sub the 2013 below for the year pulled from the csv
#  #uids = source.each {|record| puts (1..999).map {|n| "%s%03d" % [record[2],n]}}
#  #for source.index in 2 {|record| puts (1..999).map {|n| "%s%03d" % [record[2],n]}}
#end


def create_users #(user)
  # create hash of known values, then iterate over them applying string formatting for each instead of defining all here?
  # pass the file reference
  puts "please provide a file path: "
  file = STDIN.gets.chomp
  users = read_csv(file)

  # get the diradmin password in a secure fashion
  # i know the actual execution won't be secure, but you're presumably doing this on the server itself.
  begin
  	puts "please type the diradmin password: "
  	    system "stty -echo"
  	    password = $stdin.gets.chomp
  	    system "stty echo"
  	rescue NoMethodError, Interrupt
  	    system "stty echo"
  end

  # set some default shortcuts for commands here
  create = "dscl -u diradmin -P #{password} /LDAPv3/127.0.0.1 -create /Users"
  appendgroup = "dscl -u diradmin -P #{password} /LDAPv3/127.0.0.1 -append /Groups"
  mkpass = "dscl -u diradmin -P #{password} /LDAPv3/127.0.0.1 -passwd /Users"
  # change this for actual use
  nfsdir = "/Network/Servers/server.domain.com/"
  #recordname = shortname
  #nfshome =  nfsdir + keyword + "/" + shortname

  # loop through csv
  # added simple test, though it could be more robust.
  # basically, if the account exists, the statement is true.
  # it would probably be quicker to compare the csv and dscl output
  # once before instead of running dscl again within the loop.
  users.each do |user|
    if system("dscl -q /Search -read /Users/#{user[0]} >/dev/null") == true
      puts "#{user[0]} exists. not creating or modifying #{user[0]}."
    else
    #uniqueid_increment = user[2].each {|record| puts (1..999).map {|n| "%s%03d" % [record[2],n]}}
    # change puts to system to execute
    puts "#{create}/#{user[0]}"
    puts "#{create}/#{user[0]} RecordName #{user[0]}"
    puts "#{create}/#{user[0]} dsAttrTypeNative:cn " + '"' + "#{user[1]} " + "#{user[2]}" + '"'
    puts "#{create}/#{user[0]} UniqueID #{user[3]}"
    puts "#{create}/#{user[0]} GeneratedUID #{user[4]}"
    puts "#{create}/#{user[0]} PrimaryGroupID 20"
    puts "#{create}/#{user[0]} UserShell /bin/bash"
    puts "#{create}/#{user[0]} NFSHomeDirectory #{user[5]}"
    puts "#{create}/#{user[0]} HomeDirectory " +  '"' + "#{user[6]}" + '"'
    puts "#{create}/#{user[0]} dsAttrTypeStandard:RealName \n" + " #{user[8]}"
    puts "#{create}/#{user[0]} FirstName #{user[1]}"
    puts "#{create}/#{user[0]} LastName #{user[2]}"
    puts "#{create}/#{user[0]} Keywords #{user[7]}"
    # set a password and add to the appropriate year group
    #system "#{mkpass}/#{user[0]} <default password>"
    #system "#{appendgroup}/#{user[2]} GroupMembership #{shortname}"
  end
  end
end


create_users
