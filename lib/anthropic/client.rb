module Anthropic
  class Client
    include Anthropic::HTTP

    CONFIG_KEYS = %i[
      api_version
      anthropic_version
      access_token
      log_errors
      uri_base
      request_timeout
      extra_headers
    ].freeze
    attr_reader(*CONFIG_KEYS, :faraday_middleware)

    attr_accessor :chosen_model

    def initialize(config = {}, &faraday_middleware)
      CONFIG_KEYS.each do |key|
        # Set instance variables like api_type & access_token. Fall back to global config
        # if not present.
        instance_variable_set(
          "@#{key}",
          config[key].nil? ? Anthropic.configuration.send(key) : config[key]
        )
      end
      @faraday_middleware = faraday_middleware
    end

    # client.haiku.chat
    # client.sonnet.chat

    def chat(messages:, tools:, model: chosen_model, max_tokens: 1024)
      json_post(path: '/messages', parameters: { model:, messages:, max_tokens:, tools: })
    end

    def tool_chat( # rubocop:disable Metrics/MethodLength,Metrics/ParameterLists
      messages:,
      tools:,
      tool_calls: {},
      model: chosen_model,
      max_tokens: 1024,
      system: 'Only use the tools provided'
    )
      # response format {"id"=>"msg_01CkhRv3MjqS2VErhRWdgSAb", "type"=>"message", "role"=>"assistant", "model"=>"claude-3-haiku-20240307", "content"=>[{"type"=>"tool_use", "id"=>"toolu_01Hfdt4RxfTXAm65xb6QbbFE", "name"=>"calculator", "input"=>{"operand1"=>1984135, "operand2"=>9343116, "operation"=>"multiply"}}], "stop_reason"=>"tool_use", "stop_sequence"=>nil, "usage"=>{"input_tokens"=>420, "output_tokens"=>93}} # rubocop:disable Layout/LineLength

      response = json_post(path: '/messages', parameters: { model:, messages:, max_tokens:, tools:, system: })
      content = retrieve_content(response)

      if content
        input_data = convert_to_symbol_hash_keys(content['input'])
        tool = content['name']
        tool_chosen = tool_calls[tool] || tool_calls[tool.to_sym]

        tool_chosen.respond_to?(:call) ? tool_chosen.call(**input_data) : response
      elsif response['stop_reason'] == 'end_turn'
        response['content'][0]['text']
      else
        response
      end
    end

    def retrieve_content(response)
      response['content'].filter { |res| res['type'] == 'tool_use' }[0]
    end

    def convert_to_symbol_hash_keys(hash)
      hash.transform_keys(&:to_sym)
    end

    def latest_sonnet
      @chosen_model = 'claude-3-5-sonnet-20240620'
      self
    end

    def sonnet
      @chosen_model = 'claude-3-sonnet-20240229'
      self
    end

    def opus
      @chosen_model = 'claude-3-opus-20240229'
      self
    end

    def haiku
      @chosen_model = 'claude-3-haiku-20240307'
      self
    end

    def build_parameters(**kwargs)
      kwargs.inspect
    end

    def models
      @models ||= Anthropic::Models.new(client: self)
    end

    def messages
      @messages ||= Anthropic::Messages.new(client: self)
    end

    def amazon_bedrock?
      false
    end

    def vertex?
      false
    end

    # will we keep the beta trial API?
    def beta(apis)
      dup.tap do |client|
        client.add_headers("Anthropic-Beta": apis.map { |k, v| "#{k}=#{v}" }.join(';'))
      end
    end
  end
end
# what to do when stream starts
# what to do when stream ends
# when content block starts
# when content block ends
# Tool use - specify tools to use
# Stream example
# client.chat(parameters: {
#               model: 'claude-3-5-sonnet-20240620',
#               max_tokens: 1024,
#               messages: [{ "role": 'user',
#                            "content": 'Give me some active record methods and their sample code' }],
#               stream: proc do |chunk, _bytesize|
#                         print chunk.dig('delta', 'text')
#                       end
#             })
