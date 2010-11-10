#!/usr/bin/ruby
# 100330, ruby version of local admin removal bash script
=begin
- test for os version
- ternary operator used to define what runs based on os vers?
  - not needed here
- setup array of users with required local admins removed
=end

#set static local admins variable here?
def realadmins()
  # get an array of the dscl output, minus the "GroupMembership" element
  # also omit any local admins we want to keep
  static_admins=["localadmin1", "root", "localadmin2", "n8"]
end

def getos()
  # set system variable
  # chops out the second digit in the version number, which is the only differentiating factor here
  system=`/usr/bin/sw_vers -productVersion`.chomp.split(".").slice(1).to_i
  if system==4 then
    return "tiger"
  else
      return "leo"
  end
end

def getusers_leo()
  # alternate take with .reject
  #localadmins=`dscl . -read /groups/admin GroupMembership`.split(" ").slice(1..-1).reject{|e| e=="localadmin1" or e=="root" or e=="localadmin2"}
  # instead, get the list, split to make an array, slice to cut the first item, then delete the static_admins array from it to produce the other local admins
  localadmins=`dscl . -read /groups/admin GroupMembership`.split(" ").slice(1..-1)-realadmins()
end

def getusers_tiger()
  # use nicl on 10.4 to get the active local admins
  localadmins=`nicl . -read /groups/admin users`.split(" ").slice(1..-1)-realadmins()
end

def removeadmins_tiger()
  # iterate through the array of local admins and remove their admin rights
    getusers_tiger().each do |admin|
    puts "removing local admin rights for: #{admin}"
    system("nicl . -delete /groups/admin users #{admin}")
  end
end


def removeadmins_leo()
  # iterate through the array of local admins and remove their admin rights
    getusers_leo().each do |admin|
    puts "removing local admin rights for: #{admin}"
    #system("/usr/bin/dscl -delete /groups/admin GroupMembership #{admin}")
    #system("say 'removed #{admin}'")
  end
end

# do the stuff

# test the os with the getos() method and proceed accordingly based on platform
result = case getos()
  when "tiger" then
    getusers_tiger()
    removeadmins_tiger()
  when "leo" then
    getusers_leo()
    removeadmins_leo()
  else puts "no version specified. stopping..."
  end