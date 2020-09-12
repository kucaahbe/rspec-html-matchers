# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe 'working on github issues' do
  describe '#62' do # https://github.com/kucaahbe/rspec-html-matchers/issues/62
    it 'should not have html tag' do
      expect('<p>My paragraph.</p>').not_to have_tag('html')
    end

    it 'should not have body tag' do
      expect('<p>My paragraph.</p>').not_to have_tag('body')
    end
  end

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
