module Anthropic
  class Messages
    def initialize(client:)
      @client = client.beta(assistants: OpenAI::Assistants::BETA_VERSION)
    end

    def list(parameters: {})
      @client.get(path: "/messages", parameters: parameters)
    end

    def retrieve(id:)
      @client.get(path: "/messages/#{id}")
    end

    def create(parameters: {})
      @client.json_post(path: "/messages", parameters: parameters)
    end

    def modify(id:, parameters: {})
      @client.json_post(path: "/messages/#{id}", parameters: parameters)
    end
  end
end
