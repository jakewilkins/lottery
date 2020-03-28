# frozen_string_literal: true

require "dotenv"
Dotenv.load

require "sinatra/base"
require "connection_pool"
require "redis"
require "erb"
require "yaml"
require "json"
require "pathname"
require "net/http"
require "uri"

require_relative "settings"
require_relative "models/db"
require_relative "models/meeting"
require_relative "models/response"
require_relative "models/person"
require_relative "event_processor"
require_relative "command_processor"
require_relative "interaction_processor"
require_relative "zoom"


require_relative "app"
