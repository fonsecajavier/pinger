require "net/ping"
require "fileutils"

class Pinger
  def initialize(host, max_ping_fail_time = 5, log_file_name = "log.txt")
    @host = host
    @max_ping_fail_time = max_ping_fail_time
    @log_file_name = log_file_name
  end

  def call
    fail_time = nil
    FileUtils.touch(@log_file_name)

    puts "Welcome terran. We're about to ping #{@host}."
    puts "Please ensure this machine won't go to sleep. To stop, hit CTRL+C"

    while true
      sleep 1

      if host_is_up?
        fail_time = nil
        puts "PING OK"
        next
      end

      puts "PING LOST"

      if fail_time.nil?
        fail_time = Time.now
        next
      end

      now = Time.now
      elapsed_time = now - fail_time

      if elapsed_time >= @max_ping_fail_time
        err_msg = "Couldn't get response from #{@host} since #{fail_time} after #{elapsed_time.to_i} seconds"
        puts err_msg
        File.open(@log_file_name, "a") { |f| f.write(err_msg + "\n") }
        fail_time = nil
      end
    end
  end

  private

  def host_is_up?
    check = Net::Ping::External.new(@host, nil, 1)
    check.ping?
  end
end

Pinger.new("192.168.5.1").call
