# frozen_string_literal: true

module Settings
  module_function

  def zoom_bot_jid
    ENV["ZOOM_BOT_JID"]
  end

  def redis_url
    key = ENV.fetch("REDIS_PROVIDER", "REDIS_URL")

    ENV.fetch(key, "redis://localhost:6379")
  end

  def log(message)
    return unless debug?

    pp message
  end

  def zoom_verification_token
    ENV["ZOOM_VERIFICATION_TOKEN"]
  end

  def chatbot_client_id
    ENV["ZOOM_CLIENT_ID"]
  end

  def chatbot_client_secret
    ENV["ZOOM_CLIENT_SECRET"]
  end

  def root_path
    @root_path ||= Pathname.new(__FILE__).dirname.dirname
  end

  def template_path(template)
    template = "#{template}.yaml.erb" unless template.include?(".")
    root_path.join("templates").join(template)
  end

  def get_template(name)
    if (template = template_cache[name])
      return template
    end

    winner_template = template_path(name)
    template = ERB.new(winner_template.read)

    template_cache[name] = template unless debug?

    template
  end

  def template_cache
    @template_cache ||= {}
  end

  def verifyzoom
    root_path.join("verifyzoom.html")
  end

  def debug?
    ENV.key?("DEBUG")
  end
end
