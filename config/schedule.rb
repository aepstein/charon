# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :cron_log, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, { :standard => nil }
set :job_template, "/bin/bash -l -c ':job'"
job_type :runner,  'cd :path && bundle exec script/runner -e :environment ":task"'
job_type :rake,    'cd :path && RAILS_ENV=:environment /usr/bin/env bundle exec rake :task --silent :output'


every 1.hours do
#  rake 'external_registrations:import:latest'
end

every 1.days do
#  rake 'staffing:import'
end

