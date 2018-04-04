require 'open3'

module PassengerMonitor
  class Monitor

    DEFAULT_MEMORY_LIMIT = 250
    DEFAULT_WAIT_TIME = 10

    attr_accessor :memory_limit, :wait_time

    def initialize(hash={})
      self.memory_limit = hash[:memory_limit] || DEFAULT_MEMORY_LIMIT
      self.wait_time = hash[:wait_time] || DEFAULT_WAIT_TIME
    end

    def process
      passenger_memory_stats.each do |line|
        next unless processable_line?(line)

        pid, memory_usage = extract_stats(line)

        kill(pid) if bloated?(memory_usage)
      end
    end

    private

    def passenger_memory_stats
      @passenger_memory_stats ||= Open3.capture3('sudo passenger-memory-stats').first.split(/\n/)
    end

    def processable_line?(line)
      (line =~ /RubyApp: / || (line =~ /Rails: /))
    end

    def process_running?(pid)
      begin
        Process.getpgid(pid) != -1
      rescue Errno::ESRCH
        false
      end
    end

    def wait
      sleep(wait_time)
    end

    def kill(pid)
      system("sudo kill -SIGUSR1 #{pid}")
      wait
      if process_running?(pid)
        kill!(pid)
      end
    end

    def kill!(pid)
      system("sudo kill -9 #{pid}")
    end

    def extract_stats(line)
      stats = line.split
      return stats[0].to_i, stats[3].to_f
    end

    def bloated?(memory_usage)
      memory_usage > memory_limit
    end
  end
end
