# frozen_string_literal: true

module InteractionProcessor
  module_function

  def call(event)
    action, payload = event["actionItem"]["value"].split(":")

    response = case action
    when "mark-sharing"
      mark_sharing(*payload.split("."))
    when "draw-again"
      draw_again(payload)
    when "reset-shared"
      reset_shared(payload)
    end
    response.message_id = event["messageId"]

    response
  end

  def mark_sharing(meeting_id, person_id)
    meeting = Meeting.find(meeting_id)
    return unless meeting.alive?

    meeting.shared(person: person_id)

    Response.person_sharing(meeting_id)
  end

  def reset_shared(meeting_id)
    meeting = Meeting.find(meeting_id)
    return unless meeting.alive?

    meeting.clear_shared

    Response.sharing_reset(meeting_id)
  end

  def draw_again(meeting_id)
    meeting = Meeting.find(meeting_id)
    return unless meeting.alive?

    winner = meeting.draw

    if winner.empty?
      Response.empty_draw(meeting)
    else
      Response.winner(winner)
    end
  end
end
