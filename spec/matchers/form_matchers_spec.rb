require 'spec_helper'

describe "have_form" do

  before :each do
    render_html <<HTML
<form action="/books" class="formtastic book" id="new_book" method="post">
</form>
HTML
  end

  context "without &block" do

    it "should find form" do
      rendered.should have_form("/books", :post)

      self.should_receive(:have_tag).with("form#new_book", :with => { :method => "post", :action => "/books", :class => %w(book formtastic) })
      rendered.should have_form("/books", "post", :with => { :id => "new_book", :class => %w(book formtastic) })
    end

    it "should not find form" do
      rendered.should_not have_form("/some_url", :post)
      rendered.should_not have_form("/books", :get)
    end

  end

  context "with &block" do

    it "TODO"

  end
end
