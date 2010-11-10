#!/usr/bin/env ruby
# restore rights to local users who've recently had them removed.
# 5/25/10, nate@tsp
# 6/1/10, updated get_users method, cleaned up syntax, simplified

# set system variable
# chops out the second digit in the version number, which is the only differentiating factor here
def get_os
  system=`/usr/bin/sw_vers -productVersion`.chomp.split(".").slice(1).to_i
  if system==4 then
    return "tiger"
  else
      return "leo"
  end
end

# cheating by using the jamf binary.
def get_users
  users = []
  `/usr/sbin/jamf listUsers`.scan(/<name>(.*?)\<\/name>/) { users << $1 }
  users
end


# method to read admins from a text file from a removal run
# this may not be necessary if included in the restore_admin methods
def read_admins
  receipt=File.open('/Library/Receipts/com.company.removedadmins', 'r')
  return receipt.readlines
end

# use dseditgroup for 10.[5-6] clients
def restore_admin5
  if File.exist?('/Library/Receipts/com.company.removedadmins') then
    users=read_admins
    users.each do |u|
    puts "Restoring admin rights for #{u}"  
    %x(/usr/sbin/dseditgroup -o edit -a  #{u} -t user admin)
    end
  else
    users=get_users
    users.each do |u|
    puts "Restoring admin rights for #{u}"
    %x(/usr/sbin/dseditgroup -o edit -a  #{u} -t user admin)
    end
  end
end

# use nicl for 10.4 clients
def restore_admin4
  if File.exist?('/Library/Receipts/com.company.removedadmins') then
    users=read_admins
    users.each do |u|
      puts "Restoring admin rights for #{u}"
      %x(nicl -raw /var/db/netinfo/local.nidb -append /groups/admin users #{u})
  end
  else
    users=get_users
    users.each do |u|
    puts "Restoring admin rights for #{u}"
    %x(nicl -raw /var/db/netinfo/local.nidb -append /groups/admin users #{u})
    end
  end
end

# test the os with the get_os() method and proceed accordingly based on platform
result = case get_os
  when "tiger" then
    restore_admin4
  when "leo" then
    restore_admin5
  else puts "no version specified. stopping..."
  end