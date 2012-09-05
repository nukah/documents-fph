require 'bundler/capistrano'
require 'rvm/capistrano'

set :application, "FPH Document Storage"
set :repository,  "https://github.com/nukah/documents-fph.git"
set :branch, "master"
set :git_enable_submodules, 1
set :scm, :git
default_run_options[:pty] = true
set :deploy_to, "/var/www/docs.primepress"
set :deploy_via, :remote_cache
set :user, 'user'
set :use_sudo, false
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "docs.primepress.ru"                          # Your HTTP server, Apache/etc
role :app, "docs.primepress.ru"                          # This may be the same as your `Web` server
role :db,  "docs.primepress.ru", :primary => true # This is where Rails migrations will run

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
    task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end
