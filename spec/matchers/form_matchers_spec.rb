require 'spec_helper'

describe "have_form" do

  before :each do
    render_html <<HTML
<form action="/books" class="formtastic book" id="new_book" method="post">

  <div style="margin:0;padding:0;display:inline">
    <input name="authenticity_token" type="hidden" value="718WaH76RAbIVhDlnOidgew62ikn8IUCOyWLEqjw1GE=" />
   </div>

  <fieldset class="inputs">
    <ol>
      <li class="select required" id="book_publisher_input">
        <label for="book_publisher_id">
           Publisher<abbr title="required">*</abbr>
        </label>
	<select id="book_publisher_id" name="book[publisher_id]">
	  <option value=""></option>
	  <option value="1" selected="selected">The Pragmatic Bookshelf</option>
	  <option value="2">sitepoint</option>
	  <option value="3">O'Reilly</option>
	</select>
      </li>
    </ol>
  </fieldset>
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

    context "with_select" do

      it "should find select" do
	rendered.should have_form("/books", :post) do
	  with_select("book[publisher_id]", :with => { :id => "book_publisher_id" })

	  self.should_receive(:have_tag).with("select#book_publisher_id", :with => { :name => "book[publisher_id]" })
	  with_select("book[publisher_id]", :with => { :id => "book_publisher_id" })
	end
      end

      it "should not find select" do
	rendered.should have_form("/books", :post) do
	  without_select("book[publisher_id]", :with => { :id => "other_id" })

	  self.should_receive(:have_tag).with("select#book_publisher_id", :with => { :name => "koob[publisher_id]" })
	  without_select("koob[publisher_id]", :with => { :id => "book_publisher_id" })
	end
      end

      context "with_option" do

	it "should find options" do
	  rendered.should have_form("/books", :post) do
	    with_select("book[publisher_id]") do
	      with_option(nil)
	      with_option("The Pragmatic Bookshelf", :selected => true)
	      with_option(/sitepoint/,2)

	      self.should_receive(:have_tag).with('option', :with => { :value => '3' }, :text => "O'Reilly")
	      with_option("O'Reilly", 3, :selected => false)
	    end
	  end
	end

	it "should not find options" do
	  rendered.should have_form("/books", :post) do
	    with_select("book[publisher_id]") do
	      without_option("blah blah")
	      without_option("O'Reilly", 3, :selected => true)
	      without_option("O'Reilly", 100500)
	    end
	  end
	end

      end

    end

  end
end
