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

  settings = %w(ZOOM_CLIENT_ID_PROD ZOOM_CLIENT_SECRET_PROD ZOOM_BOT_JID_PROD ZOOM_VERIFICATION_TOKEN).each_with_object("") do |key, out|
    raise "Config not set: #{key}" unless ENV.has_key?(key)
    out << " #{key}=#{ENV[key]}"
  end

  system("heroku config:set --app llotto #{settings}")
end
