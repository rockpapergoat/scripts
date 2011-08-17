#!/usr/bin/env ruby
# 100810, testing
# part of the deputize scripts

def get_host
  host=%x(/usr/sbin/dsconfigad -show | /usr/bin/awk '/Computer Account/ {print $4}').chomp
  return host
  raise Error, "this machine must not be bound to AD.\n try again." if host == nil
end

def get_ou
  host = get_host
  dsout = %x(/usr/bin/dscl /Search -read /Computers/#{host}).to_a
  puts dsout.select {|item| item =~ /OU=/}.to_s.split(",")[1].gsub(/OU=/, '').chomp
end


get_ou
