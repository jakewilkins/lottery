# frozen_string_literal: true

class Person
  KEY_PATTERN = "person:%<id>s"
  ACTIVE_MEETINGS_PATTERN = "#{KEY_PATTERN}:active-meetings"

  def self.empty(meeting_id:)
    new(id: :empty, meeting_id: meeting_id, name: "Everyone has shared!")
  end

  def self.find(id:)
    new(id: id).tap {|e| e.hydrate}
  end

  def self.get(id:, name:)
    new(id: id, name: name)
  end

  attr_reader :meeting_id, :id, :name
  attr_writer :meeting_id

  def initialize(id:, name: nil, meeting_id: nil)
    @meeting_id, @id, @name = meeting_id, id, name
  end

  def participating_in(meeting_id:)
    DB do |conn|
      if !conn.exists(key)
        save
      end
      conn.hset(active_meetings_key, meeting_id, now)
    end
  end

  def empty?
    id == :empty
  end

  def cleanup(meeting_id:)
    DB do |conn|
      conn.hdel(active_meetings_key, meeting_id)
      if !conn.exists(active_meetings_key)
        conn.del(key)
      end
    end
  end

  def save
    DB { |conn| conn.set(key, name) }
  end

  def hydrate
    DB do |conn|
      @name = conn.get(key)
    end
  end

  def key
    KEY_PATTERN % {id: id}
  end

  def active_meetings_key
    ACTIVE_MEETINGS_PATTERN % {id: id}
  end

  def now
    Time.now.iso8601
  end
end
