#!/usr/bin/env ruby
# 6/1/10, alternate take on getting list of users
#
def get_users
  #users = []
  static_admins=["root", "n8", "daemon", "puppet", "nobody"]
  userlist=`/usr/bin/dscl . -list /users`.split(" ").slice(1..-1)-static_admins
  userlist.grep(/^[a-z]/) { |u| puts u }
end

get_users