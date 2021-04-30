# config valid for current version and patch releases of Capistrano
lock "~> 3.12.1"


set :stages, %w(production staging)
set :default_stage, "production"

set :application, "redmine"
set :repo_url, "https://github.com/thkernel/redmine.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml",  "config/settings.yml", "config/master.key"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor/bundle", "files"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env, { rvm_bin_path: '~/.rvm/bin' }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure


namespace :deploy do

  # Declares a task to be executed once the new code is on the server.
  after :updated, :plugin_assets do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          # Copy over plugin assets
          execute :rake, 'redmine:plugins:assets'
          # Run plugin migrations
          execute :rake, 'redmine:plugins:migrate'
        end
      end
    end
  end

  # This will run after the deployment finished and is used to reload
  # the application. You most probably have to change that depending on
  # your server setup.
=begin
  after :published, :restart do
    on roles(:app) do
      sudo "/etc/init.d/unicorn reload redmine"
    end
  end
=end
  # cleans up old versions on the server (keeping the number of releases
  # configured above)
  after :finished, 'deploy:cleanup'
end