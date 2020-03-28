# frozen_string_literal: true

class Response
  attr_reader :type, :context
  attr_accessor :message_id

  def self.winner(person)
    new(type: :winner, context: {person: person})
  end

  def self.unknown_meeting_id(id)
    new(type: :unknown_meeting_id, context: {meeting_id: id})
  end

  def self.person_sharing(id)
    new(type: :person_sharing, context: {meeting_id: id})
  end

  def self.sharing_reset(id)
    new(type: :sharing_reset, context: {meeting_id: id})
  end

  def self.empty_draw(meeting)
    new(type: :empty_draw, context: {meeting_id: meeting.id})
  end

  def self.blank
    new(type: :blank)
  end

  def initialize(type:, context: {})
    @type = type
    @context = context
  end

  def as_json(additional_context)
    # build the JSON markup for the response
    yaml = send(:"build_#{type}", additional_context)
    YAML.load(yaml)
  end

  def sendable?
    type != :blank
  end

  private

  def build_winner(additional_context)
    template = Settings.get_template("winner")
    build_context = context.dup.merge(additional_context)


    template.result_with_hash(build_context)
  end

  def build_person_sharing(additional_context)
    template = Settings.get_template("redraw_with_message")
    build_context = context.dup.merge(additional_context)
    build_context = build_context.merge({
      header: "Awesome!",
      message: "I hope they stay on topic!"
    })


    template.result_with_hash(build_context)
  end

  def build_sharing_reset(additional_context)
    template = Settings.get_template("redraw_with_message")
    build_context = context.dup.merge(additional_context)
    build_context = build_context.merge({
      header: "Nice",
      message: "The already shared list has been cleared.",
    })


    template.result_with_hash(build_context)
  end

  def build_empty_draw(additional_context)
    template = Settings.get_template("redraw_with_message")
    build_context = context.dup.merge(additional_context)
    build_context = build_context.merge({
      header: "Wow!",
      message: "Couldn't find anyone who hasn't shared, that might be everyone!",
      show_clear: true
    })


    template.result_with_hash(build_context)
  end

  def build_unknown_meeting_id(additional_context)
    template = Settings.get_template("invalid_room_name")
    build_context = context.dup.merge(additional_context)


    template.result_with_hash(build_context)
  end
end
