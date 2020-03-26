# frozen_string_literal: true

module CommandProcessor
  class Response

    def as_json
      # build the JSON markup for the response
    end

    def sendable
      false # obvs shouldn't be hardcoded
    end
  end

  COMMANDS = %i|
    draw
    help
  |

  module_function

  def call(event)
    return unless COMMANDS.include?(event["cmd"])

    # Process the command and return a response object

    Response.new
  end
end
