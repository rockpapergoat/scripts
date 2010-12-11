#!/usr/bin/ruby
# 101122, first draft of local to mobile account converter
# will pull most of this from previous "unbind, rebind, convert" shell script

def find_local_account
  system_accounts = ["_amavisd", "_appowner", "_appserver", "_ard", "_atsserver", "_calendar", "_carddav", "_clamav", "_coreaudiod", "_cvmsroot", "_cvs", "_cyrus", "_devdocs", "_dovecot", "_dpaudio", "_eppc", "_installer", "_jabber", "_lda", "_locationd", "_lp", "_mailman", "_mcxalr", "_mdnsresponder", "_mysql", "_pcastagent", "_pcastserver", "_postfix", "_qtss", "_sandbox", "_screensaver", "_securityagent", "_serialnumberd", "_softwareupdate", "_spotlight", "_sshd", "_svn", "_teamsserver", "_timezone", "_tokend", "_trustevaluationagent", "_unknown", "_update_sharing", "_usbmuxd", "_uucp", "_windowserver", "_www", "_xgridagent", "_xgridcontroller"]
  userlist=`/usr/bin/dscl . -list /users`.split(" ").slice(1..-1)-system_accounts
  userlist.grep(/^[a-z]/) { |u| puts u }
end

def check_od_account(user)
  if %x(id #{user}).include?('no such user')
    puts "no user here"
end

def convert_local(user)

end

def create_admin(user)

end


# are we root? should be.
def check_root
  if ENV['USER'] != "root"
    puts "This script must be run as root."
    exit(1)
  end
end
