module Anthropic
  # Anthropic::Models Handles the list of models currently available on anthropic
  class Models
    def initialize(client: nil)
      @client = client
    end

    def latest_sonnet
      @client.chosen_model = 'claude-3-5-sonnet-20240620'
      @client
    end

    def sonnet
      @client.chosen_model = 'claude-3-sonnet-20240229'
      @client
    end

    def opus
      @client.chosen_model = 'claude-3-opus-20240229'
      @client
    end

    def haiku
      @client.chosen_model = 'claude-3-haiku-20240307'
      @client
    end
  end
end
