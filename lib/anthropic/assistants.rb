module Anthropic
  class Assistants
    BETA_VERSION = 'v1'.freeze

    def initialize(client:)
      @client = client.beta(assistants: OpenAI::Assistants::BETA_VERSION)
    end

    def list
      @client.get(path: '/assistants')
    end

    def retrieve(id:)
      @client.get(path: "/assistants/#{id}")
    end

    def create(parameters: {})
      @client.json_post(path: '/assistants', parameters:)
    end

    def modify(id:, parameters: {})
      @client.json_post(path: "/assistants/#{id}", parameters:)
    end

    def delete(id:)
      @client.delete(path: "/assistants/#{id}")
    end
  end
end
