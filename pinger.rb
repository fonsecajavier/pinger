require "net/ping"

CHOST = "192.168.5.1"
MAX_PING_FAIL_TIME = 5
LOG_FILE = "log.txt"

def up?(host)
  check = Net::Ping::External.new(host, nil, 1)
  check.ping?
end

fail_time = Time.now

puts "Welcome terran. Please ensure this machine won't go to sleep. To stop, hit CTRL+C"

while true
  if up?(CHOST)
    puts "PING OK"
    fail_time = nil
  else
    puts "PING LOST"
    if fail_time.nil?
      fail_time = Time.now
    else
      now = Time.now
      elapsed_time = now - fail_time
      if elapsed_time >= MAX_PING_FAIL_TIME
        err_msg = "Couldn't get response from #{CHOST} at #{now} after #{elapsed_time.to_i} seconds"
        puts err_msg
        File.open(LOG_FILE, "a") { |f| f.write(err_msg + "\n") }
        fail_time = nil
      end
    end
  end
  sleep 1
end
