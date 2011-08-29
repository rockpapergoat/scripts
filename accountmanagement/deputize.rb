#!/usr/bin/env ruby
# deputize.rb
# 100616, modified version of older script
# 100617, added hash methods, rescue, more accurate ou routine
# 100617, added dummy receipt writing, logging, simplified (i think) get_ou method
# 100622, edited failure output
# 100622, edited get_ou method to exit if the correct ou isn't found
# 100624, using 'raise' instead of rescuing exceptions so the script will show in error logs
# => also removed rescue clasues in other methods so script will fail more quickly (make it less resilient)
# 100727, added method to create mobile account instead of assigning admin via dsconfigad
# 100728, tested 10.4 mobile account creation; work this into script
# 100810, added get_os method, 10.4 mobile account creation, case for OS check
# 101112, edited ou mapping and members
# 101228, edited ou mappings; fixed syntax error; removed assignment for Mac group
# 110125, resolved syntax errors in hashes, createmobile method; added check for account

# cf. http://pastie.org/pastes/1007857
# cf. http://pastie.textmate.org/private/fenl9kdmuhqxtzhmxhx9jq

def get_host
  host=%x(/usr/sbin/dsconfigad -show | /usr/bin/awk '/Computer Account/ {print $4}').chomp
  return host
  raise Error, "this machine must not be bound to AD.\n try again." if host == nil
end

def get_os
  system=`/usr/bin/sw_vers -productVersion`.chomp.split(".").slice(1).to_i
  if system==4 then
    return "tiger"
  else
      return "leo"
  end
end


def get_ou
  host = get_host
  dsout = %x(/usr/bin/dscl /Search -read /Computers/#{host}).to_a
  ou = dsout.select {|item| item =~ /OU=/}.to_s.split(",")[1].gsub(/OU=/, '').chomp
  return ou
end

def deputize(ou)
  # define a hash with the OU names mapped to deputy admin groups
  # added in the form: OU => group or account name
  # replace the OUs and account names with actual AD accounts (and remove nate)
  deputy_admins = {
    "Mac" => [""],
    "patch_excl-group1" => ["admin_first_last1"],
    "patch_excl-group2" => ["admin_first_last7", "admin_first_last3", "admin_first_last6"],
    "patch_excl-group3" => ["admin_first_last1", "admin_first_last2", "admin_first_last5"],
    "patch_excl-group4" => ["admin_first_last1", "admin_first_last2", "admin_first_last5"],
    "patch_excl-group5" => ["admin_first_last1", "admin_first_last2", "admin_first_last5"],
    "patch_excl-group6" => ["admin_first_last4"]
    }
  # actually add the correct deputy group as local admin group via dsconfigad
  if deputy_admins.has_key?("#{ou}")
    %x(/usr/bin/logger -i -t OU_ADMIN_ADDER "adding user #{deputy_admins["#{ou}"]} as local admin.")
    File.open('/Library/Receipts/org.company.ou_adder', 'w') do |line|
      line.puts %x(hostname).chomp + " is in OU #{ou}. #{deputy_admins["#{ou}"]} will be set as a local admin."
      deputy_admins["#{ou}"].each { |account| create_mobile(account) }
    end
  else
    puts %x(hostname).chomp + " is not part of this plan."
end
end

def get_users(account)
  if `dscl . -list /users`.include?(account)
    return 1 # account exists
  else
    return 0 # account doesn't exist
  end
end

def create_mobile(account)
  # add case statement for os version
  # 10.4 creates mobile accounts like this:
  # /System/Library/CoreServices/mcxd.app/Contents/Resources/MCXCacher -U <username> -h /Users/<username>
  case get_os
  when "tiger" then
    mobile = "/System/Library/CoreServices/mcxd.app/Contents/Resources/MCXCacher"
    # create the mobile account for 10.4
    if get_users(account) == 0
      %x(#{mobile} -U #{account} -h /Users/#{account})
    end
  when "leo" then
      mobile = "/System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount"
        if get_users(account) == 0
          # create the mobile account for 10.5+
          %x(#{mobile} -n #{account} -S -h /Users/#{account})
        end
  end
    # kill and kickstart directoryservice
    %x(killall -HUP DirectoryService)
    # add the user to the local admin group
    %x(/usr/sbin/dseditgroup -o edit -a  #{account} -t user admin)
    puts "#{account} is now a local admin on this #{get_host}."
end

deputize(get_ou)