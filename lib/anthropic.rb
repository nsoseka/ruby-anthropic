require 'faraday'
require 'faraday/multipart'

require_relative 'anthropic/http'
require_relative 'anthropic/client'
# require_relative "anthropic/files"
require_relative 'anthropic/images'
require_relative 'anthropic/models'
# require_relative "anthropic/assistants"
# require_relative "anthropic/threads"
require_relative 'anthropic/messages'
# require_relative "anthropic/runs"
# require_relative "anthropic/run_steps"
# require_relative "anthropic/vector_stores"
# require_relative "anthropic/vector_store_files"
# require_relative "anthropic/vector_store_file_batches"
# require_relative "anthropic/audio"
require_relative 'anthropic/version'
require_relative 'anthropic/token'

module Anthropic
  class Error < StandardError; end
  class ConfigurationError < Error; end

  class MiddlewareErrors < Faraday::Middleware
    def call(env)
      @app.call(env)
    rescue Faraday::Error => e
      raise e unless e.response.is_a?(Hash)

      logger = Logger.new($stdout)
      logger.formatter = proc do |_severity, _datetime, _progname, msg|
        "\033[31mAnthropic HTTP Error (spotted in ruby-anthropic #{VERSION}): #{msg}\n\033[0m"
      end
      logger.error(e.response[:body])

      raise e
    end
  end

  class Configuration
    attr_accessor :access_token,
                  :api_version,
                  :anthropic_version,
                  :log_errors,
                  :uri_base,
                  :request_timeout,
                  :extra_headers

    DEFAULT_API_VERSION = 'v1'.freeze
    DEFAULT_URI_BASE = 'https://api.anthropic.com/'.freeze
    DEFAULT_REQUEST_TIMEOUT = 120
    DEFAULT_LOG_ERRORS = true # show errros in development
    ACCESS_TOKEN = ''.freeze

    def initialize
      @access_token = ACCESS_TOKEN
      @anthropic_version = Anthropic::VERSION
      @api_version = DEFAULT_API_VERSION
      @log_errors = DEFAULT_LOG_ERRORS
      @uri_base = DEFAULT_URI_BASE
      @request_timeout = DEFAULT_REQUEST_TIMEOUT
      @extra_headers = {}
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Anthropic::Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  # Estimate the number of tokens in a string, using the rules of thumb from Anthropic:
  # https://help.anthropic.com/en/articles/4936856-what-are-tokens-and-how-to-count-them
  def self.rough_token_count(content = '')
    raise ArgumentError, 'rough_token_count requires a string' unless content.is_a? String
    return 0 if content.empty?

    count_by_chars = content.size / 4.0
    count_by_words = content.split.size * 4.0 / 3
    estimate = ((count_by_chars + count_by_words) / 2.0).round
    [1, estimate].max
  end
end
