# encoding: UTF-8
# frozen_string_literal: true

module RSpecHtmlMatchers
  # @api
  # @private
  class NokogiriTextHelper
    NON_BREAKING_SPACE = "\u00a0"

    def initialize text, squeeze_text = false
      @text = text
      @squeeze_text = squeeze_text
    end

    def content node_set
      node_set.find_all do |node|
        actual_content = node.content.gsub(NON_BREAKING_SPACE, ' ')
        actual_content = node.content.gsub(/\s+/, ' ').strip if @squeeze_text

        actual_content == @text
      end
    end
  end
end
