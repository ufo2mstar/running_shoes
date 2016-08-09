require 'watir-webdriver'


n=5
url = "www.google.com"


@browser = Watir::Browser.new
@browser.goto url
name_val = 'q'
# http://github.com/oneclick/rubyinstaller/wiki/Development-Kit

rand_str=-> (size) { size.times.map { ('a'..'z').to_a.sample }.join }

n.times { |i|
  str = rand_str[i+3]
  puts "time - #{i+1} = #{str}"
  @browser.text_field(name: name_val).set str
  @browser.button(type: 'submit').click
  sleep 1
  puts @browser.div(id: 'resultStats').text
}

