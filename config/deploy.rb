require "bundler/capistrano"
require "rvm/capistrano"                               # Load RVM's capistrano plugin.

set :stages, %w(production staging)
set :default_stage, "production"
require 'capistrano/ext/multistage'
set :application, "chardik"
set :repository, "git@github.com:sabril/chardik.git"
set :scm, :git
set :use_sudo, true
# ssh_options[:user] = "ubuntu"
# ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/keys/rails_app.pem"]

desc "check production task"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :deploy do
  namespace :assets do
    desc "Precompile assets"
    task :precompile, :roles => :web, :except => {:no_release => true} do
      run "cd #{release_path} && bundle exec rake assets:precompile --trace"
    end
  end
  
  namespace :db do
    desc "Run rake db:setup."
    task :setup, :roles => :db, :only => { :primary => true } do
        rake = fetch(:rake, "rake")
        rails_env = fetch(:rails_env, "production")
        migrate_env = fetch(:migrate_env, "")
        migrate_target = fetch(:migrate_target, :latest)

        directory = case migrate_target.to_sym
          when :current then current_path
          when :latest  then latest_release
          else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
          end

        run "cd #{directory} && #{rake} RAILS_ENV=#{rails_env} #{migrate_env} db:setup --trace"
      end
  end
  
  desc "Run bundle install."
  task :bundle_install, :roles => :app, :only => { :primary => true } do
    run "cd #{release_path} && bundle install --system"
  end
end
desc "Symlinks the uploads"
task :symlink_uploads, :roles => :app, :except => { :no_release => true } do
  run "rm -rf #{release_path}/public/uploads"
  run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
end

desc "Symlinks the database.yml"
task :copy_db_file, :roles => :app do
  find_servers_for_task(current_task).each do |server|
    run_locally "rsync -e 'ssh -i #{ENV['HOME']}/.ssh/chardik.pem' -vr --exclude='.DS_Store' config/database.config.yml #{user}@#{server.host}:#{release_path}/config/database.yml"
  end
end

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end

# after "deploy:update", "copy_db_file"
after "deploy:update_code", "rvm:trust_rvmrc", :symlink_uploads
before "deploy:restart", :copy_db_file, "deploy:assets:precompile"
after "deploy:restart", "deploy:cleanup"#, 'deploy:copy_db_file'