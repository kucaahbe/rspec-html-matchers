require 'spec_helper'

describe 'have_tag' do

  context "simple matching:" do

    it "should find <div>" do
      rendered.should have_tag('div')
    end

    it "should not find <strong>" do
      rendered.should_not have_tag('strong')
    end

    it "should find 3 tags <p>" do
      rendered.should have_tag('p',:count => 3)
    end

    it "should find more than 2 tags <p>" do
      pending("TODO: rendered.should have_tag('p',:count => '>2')")
    end

    it "should find more than 3(or 3) tags <p>" do
      pending("TODO: rendered.should have_tag('p',:count => '>=3')")
    end

    it "should find less than 5 tags <p>" do
      pending("TODO: rendered.should have_tag('p',:count => '<5')")
    end

    it "should find less than 3(or 3) tags <p>" do
      pending("TODO: rendered.should have_tag('p',:count => '<=3')")
    end

    it "should not find 2 or 5 tags <p>" do
      rendered.should_not have_tag('p', :count => 2)
      rendered.should_not have_tag('p', :count => 5)
    end

    it "should find text" do
      rendered.should have_tag('div', :text => 'sample text')
      rendered.should have_tag('p', :text => 'one')
      rendered.should have_tag('p', :text => 'two')
      rendered.should have_tag('p', :text => 'three')
    end

    it "should find text as regexp" do
      rendered.should have_tag('div', :text => /sample/)
    end

    it "should not find text" do
      rendered.should_not have_tag('p', :text => 'text does not present')
      rendered.should_not have_tag('strong', :text => 'text does not present')
    end

    it "should not find text as regexp" do
      rendered.should_not have_tag('p', :text => /text does not present/)
      rendered.should_not have_tag('strong', :text => /text does not present/)
    end

  end

end
