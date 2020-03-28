# frozen_string_literal: true

class Response
  RESPONSES = {
    winner: { template: "winner" },
    person_sharing: {
      template: "redraw_with_message",
      values: {
        header: "Awesome!",
        message: "I hope they stay on topic!"
      }
    },
    sharing_reset: {
      template: "redraw_with_message",
      values: {
        header: "Nice",
        message: "The already shared list has been cleared.",
      }
    },
    empty_draw: {
      template: "redraw_with_message",
      values: {
        header: "Wow!",
        message: "Couldn't find anyone who hasn't shared, that might be everyone!",
        show_clear: true
      }
    },
    unknown_meeting_id: { template: "invalid_room_name" }
  }

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

  def self.empty_draw(id)
    new(type: :empty_draw, context: {meeting_id: id})
  end

  def self.blank
    new(type: :blank)
  end

  attr_reader :type, :context
  attr_accessor :message_id

  def initialize(type:, context: {})
    @type = type
    @context = context
  end

  def as_json(additional_context)
    YAML.load(build_yaml(additional_context))
  end

  def sendable?
    type != :blank
  end

  private

  def build_yaml(additional_context)
    conf = RESPONSES.fetch(type)
    values = conf.fetch(:values, {})

    template = Settings.get_template(conf[:template])
    build_context = context.dup.merge(additional_context).merge(values)

    template.result_with_hash(build_context)
  end
end
