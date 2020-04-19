# frozen_string_literal: true

class App < Sinatra::Base
  use Rollbar::Middleware::Sinatra

  get("/privacy") { redirect to("/privacy.html") }
  get("/terms") { redirect to("/terms.html") }
  get("/support") { redirect to("https://github.com/jakewilkins/lottery/issues") }

  get "/oauth" do
    redirect "https://zoom.us/launch/chat?jid=robot_#{Settings.zoom_bot_jid}"
  end

  get "/zoomverify/verifyzoom.html" do
    Settings.verifyzoom.read
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
    payload = body["payload"]

    response = case body["event"]
    when "bot_notification"
      CommandProcessor.call(payload)
    when "interactive_message_actions"
      InteractionProcessor.call(payload)
    else
      Response.blank
    end

    Settings.log response

    if response.sendable?
      Zoom.send_message(body, response)
    end

    "ok"
  end

  post "/deauthorize" do
    return halt(403) unless valid_request?

    body = JSON.parse(request.body.read) rescue {}
    return halt(400) if body.empty?

    payload = {
      client_id: body["client_id"],
      user_id: body["user_id"],
      account_id: body["account_id"],
      deauthorization_event_received: body,
      compliance_completed: true
    }

    Zoom.post(
      'https://api.zoom.us/oauth/data/compliance',
      payload,
      authorization: :basic
    )

    "ok"
  end

  get("/") { redirect to("https://github.com/jakewilkins/lottery") }

  def valid_request?
    request.env["HTTP_AUTHORIZATION"] == Settings.zoom_verification_token
  end
end
