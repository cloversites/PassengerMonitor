module PassengerMonitor
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/passenger_monitor.rake'
    end
  end
end
