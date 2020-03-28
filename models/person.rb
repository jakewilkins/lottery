# frozen_string_literal: true

class Person
  attr_reader :meeting_id, :id, :name

  def initialize(meeting_id:, id:, name:)
    @meeting_id, @id, @name = meeting_id, id, name
  end

  def empty?
    id == :empty
  end
end
