# frozen_string_literal: true

module CommandProcessor
  COMMANDS = %i|
    draw
    help
  |

  module_function

  def call(event)
    command, args = parse_command(event["cmd"])
    return Response.blank unless COMMANDS.include?(command)
    Settings.log([command, args])

    return drawn_response(args.first, account: event["accountId"]) if command == :draw

    Response.blank
  end

  def drawn_response(meeting_id, account:)
    id = meeting_id.gsub(/([[:punct:]]| )/, '')
    meeting = Meeting.find(id, account: account)

    return Response.unknown_meeting_id(meeting_id) unless meeting.alive?

    winner = meeting.draw

    if winner.empty?
      Response.empty_draw(meeting)
    else
      Response.winner(winner)
    end
  end

  def parse_command(cmd)
    command, args = cmd.split(" ", 2)
    command = command.downcase.intern

    [command, args.split(" ")]
  end
end
