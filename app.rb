# frozen_string_literal: true

require_relative "setup"

class App < Sinatra::Base
  get "/oauth" do
    redirect "https://zoom.us/launch/chat?jid=robot_#{Settings.zoom_bot_jid}"
  end

  post "/hook" do
    return halt(403) unless valid_request?

    body = JSON.parse(request.body.read) rescue {}
    Settings.log body

    EventProcessor.call(body)

    "ok"
  end

  post "/command" do
    return halt(403) unless valid_request?

    body = JSON.parse(request.body.read) rescue {}
    Settings.log body

    # Is the command processor going to handle button actions too or do I filter
    # that here into and handle it in a separate module
    response = CommandProcessor.call(body)
    Settings.log response

    if response.sendable?
      Zoom.send_message(response)
    end

    "ok"
  end

  post "/deauthorize" do
  # if (req.headers.authorization === process.env.zoom_verification_token) {
  #   res.status(200)
  #   res.send()
  #   request({
  #     url: 'https://api.zoom.us/oauth/data/compliance',
  #     method: 'POST',
  #     json: true,
  #     body: {
  #       'client_id': req.body.payload.client_id,
  #       'user_id': req.body.payload.user_id,
  #       'account_id': req.body.payload.account_id,
  #       'deauthorization_event_received': req.body.payload,
  #       'compliance_completed': true
  #     },
  #     headers: {
  #       'Content-Type': 'application/json',
  #       'Authorization': 'Basic ' + Buffer.from(process.env.zoom_client_id + ':' + process.env.zoom_client_secret).toString('base64'),
  #       'cache-control': 'no-cache'
  #     }
  #   }, (error, httpResponse, body) => {
  #     if (error) {
  #       console.log(error)
  #     } else {
  #       console.log(body)
  #     }
  #   })
  # } else {
  #   res.status(401)
  #   res.send('Unauthorized request to Unsplash Chatbot for Zoom.')
  # }
  end

  def valid_request?
    request.env["HTTP_AUTHORIZATION"] == Settings.zoom_verification_token
  end
end
