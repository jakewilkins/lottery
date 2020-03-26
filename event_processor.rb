# frozen_string_literal: true

module EventProcessor
  EVENT_TYPES = %w|
    meeting.participant_joined
    meeting.participant_left
    meeting.ended
  |
  module_function
  def call(event)
    return unless EVENT_TYPES.include?(event["event"])

    method = event["event"].gsub(".", "_").intern

    public_send(method, event["payload"]["object"])
  end

  def meeting_participant_joined(event)
    meeting = Meeting.find(event["uuid"])

    meeting << {id: event["participant"]["user_id"], name: event["participant"]["user_name"]}
  end

  def meeting_participant_left(event)
    meeting = Meeting.find(event["uuid"])
    return unless meeting.alive?

    meeting << {id: event["participant"]["user_id"]}
  end

  def meeting_ended(event)
    meeting = Meeting.find(event["uuid"])
    return unless meeting.alive?

    meeting.cleanup
  end

end
