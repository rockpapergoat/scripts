#!/usr/bin/env ruby -wKU

def test_user(user)
  search = %x(dscl /Search -read /Users/#{user} 2>&1)
  if search.include?("eDSRecordNotFound")
    puts "#{user} not found"
  else
    puts "#{user} exists"
  end
end

if ARGV.size > 0
  test_user(ARGV[0])
else
  puts "pass me a name"
end
