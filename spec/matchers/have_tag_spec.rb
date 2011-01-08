require 'spec_helper'

describe 'have_tag' do
  it "should find tag" do
    rendered.should have_tag('div')
  end
end
