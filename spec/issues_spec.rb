# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe 'working on github issues' do
  it '#73' do # https://github.com/kucaahbe/rspec-html-matchers/issues/73
    rendered = <<HTML
      <p>
         content with ignored
         spaces
         around
      </p>
HTML
    expect(rendered).to have_tag('p', :seen => 'content with ignored spaces around')
  end
end
