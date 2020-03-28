# frozen_string_literal: true

module InteractionProcessor
  module_function

  def call(event)
    action, payload = event["actionItem"]["value"].split(":")

    response = case action
    when "mark-sharing"
      mark_sharing(*payload.split("."))
    when "draw-again"
      draw_again(*payload.split("."))
    when "reset-shared"
      reset_shared(*payload.split("."))
    end
    response.message_id = event["messageId"]

    response
  end

  def mark_sharing(account_id, meeting_id, person_id)
    meeting = Meeting.find(meeting_id, account: account_id)
    return unless meeting.alive?

    meeting.shared(person: person_id)

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
