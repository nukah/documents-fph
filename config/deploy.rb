require 'bundler/capistrano'
require 'rvm/capistrano'

set :application, "FPH Document Storage"
set :repository,  "https://github.com/nukah/documents-fph.git"
set :domain_dir, 'docs.primepress'
set :rvm_type, :system
set :rvm_bin_path, '/usr/local/rvm/bin'
set :rvm_ruby_string, '1.9.3@documents'
set :branch, "master"
set :git_enable_submodules, 1
set :scm, :git
default_run_options[:pty] = true
set :deploy_to, "/var/www/#{domain_dir}"
set :deploy_via, :remote_cache
set :user, 'user'
set :use_sudo, false
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
server "docs.primepress.ru", :app, :web, :db, :primary => true

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"
after "deploy:setup", "deploy:db:setup" unless fetch(:skip_db_setup, false)
after "deploy:create_symlink", "deploy:precompile_assets"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts
namespace :db do
  desc "Creates Postgres database and appropriate user"
  task :setup do
    password = Capistrano::CLI.password_prompt
    commands = ""
    commands << "CREATE USER #{user} WITH PASSWORD #{password};"
    commands << "CREATE DATABASE primepress;"
    commands << "GRANT ALL PRIVELEGES ON DATABASE primepress TO #{user};"
    run "sudo -u postgres psql < #{commands.to_s}"

    database_template = <<-EOF
      production:
        database: primepress
        adapter: postgresql
        username: #{user}
        password: #{password}
        encoding: unicode
        host: localhost
        pool: 5
    EOF

    database_yml = ERB.new(database_template).result(binding)
    put database_yml, "#{current_path}/config/database.yml"
  end
end
# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
    desc "Zero-downtime restart of Unicorn"
      task :restart, :except => { :no_release => true } do
        run "kill -s USR2 `cat /tmp/unicorn.#{domain_dir}.pid`"
    end

    desc "Start unicorn"
      task :start, :except => { :no_release => true } do
        run "cd #{current_path} ; bundle exec unicorn_rails -c config/unicorn.rb -D"
    end

    desc "Stop unicorn"
      task :stop, :except => { :no_release => true } do
        run "kill -s QUIT `cat /tmp/unicorn.#{domain_dir}.pid`"
    end

    desc "Precompile assets"
      task :precompile_assets, :except => { :no_release => true } do
        run "bundle exec rake assets:precompile"
      end
end