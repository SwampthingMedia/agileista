set :application, "featurecloud.com"
set :repository, "git@github.com:levent/agileista.git"
set :scm, :git
set :deploy_via, :remote_cache
# set :deploy_via, :copy
# set :copy_cache, true
# set :copy_exclude, [".git"]
# set :branch, "0.3.5"
set :scm_verbose, true

# set :deploy_via, :export
# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/levent/apps/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
ssh_options[:port] = 40000
set :port, 40000
set :user, "levent"
set :use_sudo, false
default_run_options[:pty] = true

set :application, "featurecloud.com"
set :rails_env, "staging"
role :app, "featurecloud.com"
role :web, "featurecloud.com"
role :db,  "featurecloud.com", :primary => true

namespace :deploy do
  task :restart do
    restart_sphinx
    run "touch #{release_path}/tmp/restart.txt"
  end
end

namespace :deploy do
  task :stop do
    run "touch #{release_path}/tmp/restart.txt"
  end
end

namespace :deploy do
  task :start do
    run "touch #{release_path}/tmp/restart.txt"
  end
end

desc "Stop the sphinx server"
task :stop_sphinx , :roles => :app do
  run "cd #{current_path} && rake ts:stop RAILS_ENV=#{rails_env}"
end


desc "Start the sphinx server" 
task :start_sphinx, :roles => :app do
  run "cd #{current_path} && rake ts:config RAILS_ENV=#{rails_env} && rake ts:start RAILS_ENV=#{rails_env}"
end

desc "Restart the sphinx server"
task :restart_sphinx, :roles => :app do
  stop_sphinx
  start_sphinx
end

desc "Reindex search index"
task :reindex_sphinx, :roles => :app do
  run "cd #{current_path} && rake ts:index RAILS_ENV=#{rails_env}"
end

task :setup_symlinks, :roles => :web do
  run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{shared_path}/sphinx #{release_path}/db/sphinx"
end

after "deploy:update_code", :setup_symlinks
after "deploy", "deploy:cleanup"