require 'csv'
require 'net/http'
# for the "SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed (OpenSSL::SSL::SSLError)"
# OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# Input
input_file  =
    # 'sid.txt'
'all.txt'
# 'ipb_2.txt'
# 'pba_2.txt'

# code setup
cur_dir     = File.dirname(__FILE__)
$timestamp  = Time.now.strftime "%Y-%m-%d_%H-%M-%S_users"
out_name    = cur_dir+"/result/#{$timestamp}_#{input_file.gsub('.txt','')}.csv"
in_name     = Dir.glob(cur_dir+"/**/#{input_file}")[0]
lob_inp     = Dir.glob(cur_dir+"/**/lob.txt")[0]

# list setup
sid_list    = File.readlines(in_name).map(&:chomp)
region_list = File.readlines(lob_inp).map(&:chomp)

# debug
def show ary
  puts "#{ary.join("\t")}"
end

# CSV gen
CSV.open(out_name, "w") do |csv|
  csv << region_list
  sid_list.each do |row|
    # title row print
    # if row[0] == "Name"
    #   out = [row] + region_list
    #   csv << out
    #   show out
    #   next
    # end
    # non-sid line print
    unless row =~ /(\w\d{6})/
      out = [row]
      csv << out
      show out
      next
    end
    sid         = $1
    csv_str_ary = [row, sid]
    # todo: can Hash the values for redundancy reduction
    region_list[2..-1].each do |region|
      url = "http://url/astandardid=#{sid}&bankcode=#{region}&applicationname=TEST"
      uri   = URI(url)
      resp  = Net::HTTP.get(uri)
      check = case resp
                when /JpmCreditEdit/
                  "PBA"
                when /WMCreditIntlGeneric/
                  # "1"
                  region
                else
                  nil
              end
      csv_str_ary << (check || "-")
    end
    csv << csv_str_ary
    show (csv_str_ary[1..-1] << "  =  " << csv_str_ary[0])
  end
end
