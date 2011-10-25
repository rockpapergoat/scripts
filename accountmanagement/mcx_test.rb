#!/usr/bin/env ruby -wKU

def get_prefs
  prefs = Dir.glob("/etc/mcx/*.mcx")
end

def chop_users(prefs)
  users = []
  if prefs == []
    puts "no prefs to process; quitting."
    exit(1)
  else
    prefs.each do |pref|
      users << pref.split("/").last.sub(/.mcx/, "")
    end
  end
  users
end

def test_user(users)
  raise ArgumentError unless users.class != "Array"
  p users
end

p test_user(chop_users(get_prefs))