module Anthropic
  # Anthropic::Tools handles custom tools you setup to tune Claude
  class Tools
    def initialize(client: nil)
      @client = client
    end
  end
end

# tool chat example
# require_relative './lib/anthropic'
# client = Anthropic::Client.new

# calculator = proc do |operation:, operand1:, operand2:|
#   case operation.to_sym
#   when :add
#     operand1 + operand2
#   when :subtract
#     operand1 - operand2
#   when :multiply
#     operand1 * operand2
#   when :divide
#     operand1 / operand2
#   else
#     raise ValueError "We don't know what you want"
#   end
# end

# cannot_calculate = proc { puts 'Something went wrong' }

# calculator_tool = {
#   "name": 'calculator',
#   "description": 'A simple calculator that performs basic arithmetic operations.',
#   "input_schema": {
#     "type": 'object',
#     "properties": {
#       "operation": {
#         "type": 'string',
#         "enum": %w[add subtract multiply divide],
#         "description": 'The arithmetic operation to perform.'
#       },
#       "operand1": {
#         "type": 'number',
#         "description": 'The first operand.'
#       },
#       "operand2": {
#         "type": 'number',
#         "description": 'The second operand.'
#       }
#     },
#     "required": %w[operation operand1 operand2]
#   }
# }
# client.latest_sonnet.tool_chat(model: 'claude-3-haiku-20240307',
#                                messages: [{ "role": 'user',
#                                             "content": 'Please can you give me the result of multiplying 100 by 8.93?' }],
#                                max_tokens: 300,
#                                tools: [calculator_tool],
#                                tool_calls: {
#                                  calculator:
#                                })
