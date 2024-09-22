module Anthropic
  module HTTPHeaders
    def add_headers(headers)
      @extra_headers = extra_headers.merge(headers.transform_keys(&:to_s))
    end

    private

    def headers
      anthropic_headers.merge(extra_headers)
    end

    def anthropic_headers
      {
        'x-api-key' => @access_token,
        'anthropic-version' => @anthropic_version,
        'Content-Type' => 'application/json'
      }
    end

    def extra_headers
      @extra_headers ||= {}
    end
  end
end
