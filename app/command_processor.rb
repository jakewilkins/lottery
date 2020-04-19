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

    return drawn_response(args.first, event: event) if command == :draw

    Response.blank
  end

  def drawn_response(meeting_id, event:)
    id = meeting_id.gsub(/([[:punct:]]| )/, '')
    account = event['accountId']
    user_id = event['userId']
    meeting = Meeting.find(id, account: account)
    person = Person.find(id: user_id)

    return Response.unknown_meeting_id(meeting_id) unless meeting.alive?
    return Response.unknown_meeting_id(meeting_id) unless person.in?(meeting_id: meeting.id)

    winner = meeting.draw

    if winner.empty?
      Response.empty_draw(meeting.id)
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
