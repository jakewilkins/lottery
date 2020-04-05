# frozen_string_literal: true

module Zoom
  module_function

  def send_message(body, response)
    additional_context = {
      account_id: body["payload"]["accountId"],
      to_jid: body["payload"]["toJid"],
      robot_jid: body["payload"]["robotJid"]
    }

    json_hash = response.as_json(additional_context)

    if response.message_id
      Settings.log "updating message #{response.message_id}\n#{json_hash}"
      put "im/chat/messages/#{response.message_id}", json_hash
    else
      Settings.log "sending: #{json_hash}"
      post "im/chat/messages", json_hash
    end
  end

  def post(endpoint, body)
    uri = build_uri(endpoint)
    req = Net::HTTP::Post.new(uri, {'Content-Type': 'text/json'})
    req["Authorization"] = "Bearer #{get_chatbot_token}"
    req.body = body.to_json

    res = send_request(uri, req)

    case res
    when Net::HTTPSuccess
      :ok
    else
      Settings.debug do
        puts response.class
        puts response.body

        if ENV["DEBUG"] == 2
          require "pry"; binding.pry
        end
      end
    end
  end

  def put(endpoint, body)
    uri = build_uri(endpoint)
    req = Net::HTTP::Put.new(uri, {'Content-Type': 'text/json'})
    req["Authorization"] = "Bearer #{get_chatbot_token}"
    req.body = body.to_json

    res = send_request(uri, req)

    case res
    when Net::HTTPSuccess
      :ok
    else
      require "pry"; binding.pry
    end
  end

  def get_chatbot_token
    @chatbot_token_cache ||= {}

    if (expires_in = @chatbot_token_cache[:expires_in]) && expires_in > Time.now.to_i
      return @chatbot_token_cache[:access_token]
    end

    uri = URI("https://api.zoom.us/oauth/token?grant_type=client_credentials")
    req = Net::HTTP::Post.new(uri)
    req.basic_auth(Settings.chatbot_client_id, Settings.chatbot_client_secret)

    res = send_request(uri, req)

    case res
    when Net::HTTPSuccess
      json = JSON.parse(res.body)
      @chatbot_token_cache[:expires_in] = (Time.now + json["expires_in"]).to_i
      @chatbot_token_cache[:access_token] = json["access_token"]
    end

    @chatbot_token_cache[:access_token]
  end

  def send_request(uri, req)
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
  end

  def build_uri(ep)
    ep = "/#{ep}" unless ep[0] == "/"
    URI("https://api.zoom.us/v2#{ep}")
  end
end
