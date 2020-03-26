# frozen_string_literal: true

module DB
  module_function

  def pool
    @pool ||= ConnectionPool.new(size: 4, timeout: 2) do
      Redis.new(url: Settings.redis_url)
    end
  end

  def connection(&block)
    pool.with(&block)
  end
end

def DB(conn = nil, &block)
  return block.call(conn) if conn
  DB.connection(&block)
end
