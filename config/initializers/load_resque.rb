require 'resque'

Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

# Workers sleep for 3 seconds (default is 5 seconds)
ENV['INTERVAL'] = '3'
# 
# Workers work on more jobs before suicide. See death notes at https://github.com/staugaard/resque-multi-job-forks
ENV['MINUTES_PER_FORK'] = '5'
