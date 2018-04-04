require 'passenger_monitor'

namespace :passenger_monitor do
  task check_and_remove_bloated: :environment do
    PassengerMonitor::Monitor.new.process
  end
end
