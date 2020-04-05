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

    public_send(method, event["payload"])
  end

  def meeting_participant_joined(event)
    Settings.debug(event)
    account_id = event["accountId"]
    event = event["object"]
    meeting = Meeting.find(event["id"], account: account_id)
    person = Person.get(id: event["participant"]["user_id"], name: event["participant"]["user_name"])

    meeting << person
  end

  def meeting_participant_left(event)
    Settings.debug(event)
    account_id = event["accountId"]
    event = event["object"]
    meeting = Meeting.find(event["id"], account: account_id)
    return unless meeting.alive?

    person = Person.find(id: event["participant"]["user_id"])

    meeting >> person
  end

  def meeting_ended(event)
    Settings.debug(event)
    account_id = event["accountId"]
    event = event["object"]
    meeting = Meeting.find(event["id"], account: account_id)
    return unless meeting.alive?

    meeting.cleanup
  end

end
