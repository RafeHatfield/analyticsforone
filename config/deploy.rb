# For complete deployment instructions, see the following support guide:
# http://www.engineyard.com/support/guides/deploying_your_application_with_capistrano

require "eycap/recipes"

# =================================================================================================
# ENGINE YARD REQUIRED VARIABLES
# =================================================================================================
# You must always specify the application and repository for every recipe. The repository must be
# the URL of the repository you want this recipe to correspond to. The :deploy_to variable must be
# the root of the application.

set :keep_releases,       5
set :application,         "suite101"
set :user,                "suite101"
set :password,            "YB4mU1f6jG86f"
set :deploy_to,           "/data/#{application}"
set :monit_group,         "suite101"
set :runner,              "suite101"
set :repository,          "git@github.com:suite101/stats.git"
set :scm,                 :git
# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision,       lambda { source.query_revision(revision) { |cmd| capture(cmd) } }
set :production_database, "stats_com_production"
set :production_dbhost,   "suite101-psql-production-master"
set :staging_database,    "stats_com_staging"
#set :staging_dbhost,      "suite101-psql-staging-master"
set :staging_dbhost,      "localhost"
set :dbuser,              "suite101_db"
set :dbpass,              "632bVy6Le3h9f"

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false

# =================================================================================================
# ROLES
# =================================================================================================
# You can define any number of roles, each of which contains any number of machines. Roles might
# include such things as :web, or :app, or :db, defining what the purpose of each machine is. You
# can also specify options that can be used to single out a specific subset of boxes in a
# particular role, like :primary => true.

task :production do
  role :web, "209.251.186.100:7003" # suite101 [mongrel,memcached,redis,resque] [suite101-psql-production-master]
  role :app, "209.251.186.100:7003", :mongrel => true, :memcached => true, :redis => true, :resque => true
  role :db , "209.251.186.100:7003", :primary => true
  role :app, "209.251.186.100:7004", :mongrel => true, :memcached => true, :redis => true, :resque => true
  set :rails_env, "production"
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
end
task :staging do
  role :web, "209.251.186.100:7000" # suite101 [mongrel,memcached,redis,resque] [suite101-psql-staging-master]
  role :app, "209.251.186.100:7000", :memcached => true, :redis => true, :resque => true
  role :db , "209.251.186.100:7000", :primary => true
  set :rails_env, "staging"
  set :environment_database, defer { staging_database }
  set :environment_dbhost, defer { staging_dbhost }
end

# =================================================================================================
# desc "Example custom task"
# task :suite101_custom, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
#   run <<-CMD
#     echo "This is an example"
#   CMD
# end
# 
# after "deploy:symlink_configs", "suite101_custom"
# =================================================================================================

# Do not change below unless you know what you are doing!
after "deploy", "deploy:cleanup"
after "deploy:migrations" , "deploy:cleanup"
after "deploy:update_code", "deploy:symlink_configs", "deploy:restart_passenger"
# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"

namespace :resque do
  desc "After update_code you want to restart the workers"
  task :restart, :roles => [:app], :only => {:resque => true} do
    run "sudo monit restart all -g resque_#{application}" 
    run 'sudo monit restart all -g resque_workers'
  end
  after "deploy:symlink_configs","resque:restart"
end

namespace :deploy do 
  task :restart_passenger, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end

# cap staging rake:invoke task=resque:retry_jobs
# cap production rake:invoke task=resque:retry_jobs
namespace :rake do  
  desc "Run a task on a remote server."  
  # run like: cap staging rake:invoke task=a_certain_task  
  task :invoke do  
    run("cd #{deploy_to}/current; /usr/bin/env rake #{ENV['task']} RAILS_ENV=#{rails_env} &")  
  end  
end