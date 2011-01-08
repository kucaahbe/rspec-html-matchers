require 'spec_helper'

describe 'have_tag' do
  it "should find <div>" do
    rendered.should have_tag('div')
  end

  it "should not find <strong>" do
    rendered.should_not have_tag('strong')
  end
end
