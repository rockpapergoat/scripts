#!/usr/bin/env ruby -wKU
# 101210, nate@tsp
# 1. unbind from any existing OD server
# 2. remove old local (portable home) account reference
# 3. bind to new OD, verify lookup
# 4. recreate mobile account using existing locally cached homedir (which we don't touch at all)
# 5. optional: add user to local admin group
#
# NOTE: the local user on which you're operating should be logged out before proceeding

def delete_local(user)
  if %x(dscl . -list /users).include?(user)
    puts "deleting local cached user: #{user}"
    system "dscl . -delete /users/#{user}"
  else
    puts "\n#{user} doesn't exist on this machine."
    puts "\nlet's quit here."
    exit 1
  end
end

def remove_od(pass)
  # remove the old od config
  # setup an array of the servers in current config
  old=%x(dscl localhost -list /LDAPv3).split("\n")
  hostname=%x(hostname).chomp
  old.each do |server|
	  puts "removing the old OD config for: #{server}"
	  %x(dsconfigldap -v -r #{server} -c #{hostname} -u diradmin -p #{pass})
	  # remove the old server from the search and contacts paths
	  puts "removing the old search paths..."
	  %x(dscl /Search -delete / CSPSearchPath /LDAPv3/#{server})
	  %x(dscl /Search/Contacts -delete / CSPSearchPath /LDAPv3/#{server})
    puts "verifying removal. you should see nothing here."
    puts %x(dscl localhost -list /LDAPv3).split("\n")
  end
end

def bind_od(server, pass)
  hostname=%x(hostname).chomp
  puts "binding to OD master: #{server}"
  %x(dsconfigldap -v -f -a #{server} -n #{server} -c #{hostname} -u diradmin -p #{pass})
  puts "adding search paths for #{server}."
  # create and add the new ldap node to the search policy
  %x(dscl -q localhost -create /Search SearchPolicy dsAttrTypeStandard:CSPSearchPath)
	%x(dscl -q localhost -merge /Search CSPSearchPath /LDAPv3/#{server})
	# create and add the new ldap node for contacts lookups
	%x(dscl -q localhost -create /Contact SearchPolicy dsAttrTypeStandard:CSPSearchPath)
	%x(dscl -q localhost -merge /Contact CSPSearchPath /LDAPv3/#{server})
	%x(killall -HUP DirectoryService)
end

def verify_bind
  # use this to verify the bind works.
  # ideally, this test account only exists on the new od server.
  test_account="bindtest"
  if %x(dscl /Search -read /Users/#{test_account})
    puts "a lookup shows #{test_account} exists. you're bound."
  else
    puts "lookup of #{test_account} failed. try again or wait a minute to test."
  end
end

def create_mobile(user)
  # this should use the appropriate homedir path on the server based
  # and also enable homesync as defined via managed prefs.
  puts "creating a mobile account for user: #{user}"
  %x(/System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n #{user} -v -h /Users/#{user} -s)
end

def make_admin(user)
  # add user to local admin group (optional)
  puts "adding #{user} to local admin group."
  %x(/usr/sbin/dseditgroup -o edit -a  #{user} -t user admin)
end


if ENV["USER"] != "root"
  puts "you're not root. try again as root."
else
  if ARGV.size < 2
    puts "\nyou passed fewer than 2 arguments. try again with all required."
    puts "\nexample: #{$0} username diradmin_password admin"
    puts "\n\tat least the first two are required."
    puts "\n\tlast argument is 'admin' if you want the account to be a local admin."
      else
      if ARGV.size >= 2
        # change this or pass it as an arg.
        # if passed, modify this portion to require 3 args
        # and pass it to the bind_od() method below.
        server="odmaster.domain.com"
  
        delete_local(ARGV[0])
        remove_od(ARGV[1])
        bind_od(server)
        verify_bind
        create_mobile(ARGV[0])
      end
    end
end

#optional add to admin group
make_admin(ARGV[0]) if ARGV[2] == "admin"
