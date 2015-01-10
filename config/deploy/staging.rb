set :user, "developer1"
server "23.21.177.6", :app, :web, :db, :primary => true
ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/chardik.pem"]
set :deploy_to, "/var/www/chardik/staging"