#!/usr/bin/env ruby -wKU
# 110208, testing routines to eliminate parens from hostnames on os x clients
# 110215, fixed syntax error, added facility to accept multiple args

def chop_parens(*args)
  args.each do |name|
    if name.match(/\(\d+\)/)
       cleanedup = name.gsub(/\(\d+\)/, "").strip
       ["ComputerName", "HostName", "LocalHostName"].each do |label|
         system "scutil --set #{label} #{cleanedup}"
         puts "#{label} is: " + `scutil --get #{label}`
       end
    else
      puts "no parens in name: #{name}"
    end
  end
end

cname = `scutil --get ComputerName`.chomp
hname = `scutil --get HostName`.chomp
lname = `scutil --get LocalHostName`.chomp
chop_parens(cname, hname, lname)