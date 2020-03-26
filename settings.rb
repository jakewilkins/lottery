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

  def debug?
    ENV.key?("DEBUG")
  end
end
