# frozen_string_literal: true

module InteractionProcessor
  module_function

  def call(event)
    action, payload = event["actionItem"]["value"].split(":")
    payload = payload.split(".")

    Settings.debug do
      puts "processing #{action} with args #{payload.inspect}"
    end

    response = case action
    when "mark-sharing"
      mark_sharing(*payload)
    when "draw-again"
      draw_again(*payload)
    when "reset-shared"
      reset_shared(*payload)
    end
    response.message_id = event["messageId"]

    response
  end

  def mark_sharing(account_id, meeting_id, person_id)
    meeting = Meeting.find(meeting_id, account: account_id)
    return unless meeting.alive?

    person = Person.find(id: person_id)
    meeting.shared(person)

    Response.person_sharing(meeting_id)
  end

  def reset_shared(account_id, meeting_id)
    meeting = Meeting.find(meeting_id, account: account_id)
    return unless meeting.alive?

    meeting.clear_shared

    Response.sharing_reset(meeting_id)
  end

  def draw_again(account_id, meeting_id)
    meeting = Meeting.find(meeting_id, account: account_id)
    return unless meeting.alive?

    winner = meeting.draw

    if winner.empty?
      Response.empty_draw(meeting)
    else
      Response.winner(winner)
    end
  end
end
