# ?
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

desc "Upload .env vars to heroku"
task :push_env do
  require "dotenv"
  Dotenv.load

  suffix = ""
  unless ENV["ENV"] == "dev"
    suffix = "_PROD"
  end

  settings = %w(ZOOM_CLIENT_ID ZOOM_CLIENT_SECRET ZOOM_BOT_JID ZOOM_VERIFICATION_TOKEN).each_with_object("") do |key, out|
    set = "#{key}#{suffix}"
    raise "Config not set: #{set}" unless ENV.has_key?(set)
    out << " #{set}=#{ENV[set]}"
  end

  system("heroku config:set --app llotto #{settings}")
end

task default: :test
