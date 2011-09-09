#!/usr/bin/env ruby
# get a machine's applecare warranty expiration
# 100605, nate, initial version
# 100605, updated with collaboration from glarizza
# cf. http://pastie.org/993496
# cf. http://pastie.org/994884, with facter attribute additions
# 101222, require rubygems, facter; used facter to get serial (not as portable)
# 101222, reverted to system_profiler, as it requires fewer dependencies
# 110208, new url worked out by gary
# 110208, openssl workaround, cf. http://snippets.aktagon.com/snippets/370-Hack-for-using-OpenURI-with-SSL
# 110908, see alternate version using hashes here and here:
# cf. https://github.com/chilcote/warranty/blob/master/warranty.rb
# cf. https://github.com/glarizza/scripts/blob/master/ruby/warranty.rb 

=begin

to do: add option parsing using optparse
to do: accept file of serials or input other than stdin

=end

require 'open-uri'
require 'openssl'


def get_warranty_end(serial)
  open('https://selfsolve.apple.com/warrantyChecker.do?sn=' + serial.upcase + '&country=USA') {|item|
       item.each_line {|item|}
       warranty_array = item.strip.split('"')
       coverage = warranty_array.index('COV_END_DATE')+2
       purchase = warranty_array.index('PURCHASE_DATE')+2
       puts "\nMachine serial:\t#{serial}"
       puts "Purchase date:\t#{warranty_array[purchase]}"
       puts "Coverage end:\t#{warranty_array[coverage]}\n"
     }
end


OpenSSL::SSL::VERIFY_NONE

if ARGV.size > 0 then
  serial = ARGV.each do |serial|
    get_warranty_end(serial.upcase)
  end
  else
    puts "Without your input, we'll use this machine's serial number."
    #facts = Facter.to_hash
    #serial = "#{facts["sp_serial_number"]}" if facts.include?("sp_serial_number")
    #gets.chomp.upcase
    serial = %x(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}').upcase.chomp
    get_warranty_end(serial)
end