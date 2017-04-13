# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc "Add a new candidate submission to git"
task :new_submission, [:zip_file,:candidate_name] do |t,args|
  zip_file_path = File.absolute_path(args.zip_file)
  FileUtils.mkdir_p "submission"
  chdir "submission" do
    puts `unzip #{zip_file_path}`
    extracted_dir = Dir["*"].reject { |_| _ =~ /^\_/ }.first # let's hope!
    chdir extracted_dir do
      puts `rsync --exclude .git --exclude tmp --exclude logs --exclude submission --exclude __MACOSX -av  --delete . ../..`
    end
  end
  FileUtils.rm_rf 'submission'
  puts `git checkout -b #{args.candidate_name.gsub(/\s/,'-').downcase}`
  raise unless $?.success?
  puts `git add .`
  raise unless $?.success?
  puts `git commit -m "#{args.candidate_name}"`
  raise unless $?.success?

  puts "After reviewing the commit, push the branch to Github:"
  puts "git push origin #{args.candidate_name.gsub(/\s/,'-').downcase}"
end
