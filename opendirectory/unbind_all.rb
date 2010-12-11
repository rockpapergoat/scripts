#!/usr/bin/env ruby -wKU
# 101210, nate, method to unbind from all OD servers

def remove_od(pass)
  # remove the old od config
  # setup an array of the servers in current config
  old=%x(dscl localhost -list /LDAPv3).split("\n")
  hostname=%x(hostname).chomp
  old.each do |server|
	  puts "removing the old OD config for: #{server}"
	  system "dsconfigldap -v -r #{server} -c #{hostname} -u diradmin -p #{pass}"
	  # remove the old server from the search and contacts paths
	  puts "removing the old search paths..."
	  system "dscl /Search -delete / CSPSearchPath /LDAPv3/#{server}"
	  system "dscl /Search/Contacts -delete / CSPSearchPath /LDAPv3/#{server}"
    puts "verifying removal. you should see nothing here."
    puts  %x(dscl localhost -list /LDAPv3).split("\n")
  end
end

remove_od("pass")