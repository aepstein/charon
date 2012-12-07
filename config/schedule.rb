set :output, { :standard => nil }
every 1.hours do
  rake 'external_registrations:import:latest'
end

every 1.days do
  rake 'staffing:import'
end

