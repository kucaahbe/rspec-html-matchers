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

      <li class="string required" id="book_title_input">
      <label for="book_title">
        Title<abbr title="required">*</abbr>
      </label>
        <input id="book_title" maxlength="255" name="book[title]" size="50" type="text" />
      </li>

      <li class="string required" id="book_author_input">
      <label for="book_author">
        Author<abbr title="required">*</abbr>
      </label>
        <input id="book_author" maxlength="255" name="book[author]" size="50" type="text" value="Authorname" />
      </li>

      <li class="password optional" id="user_password_input">
      <label for="user_password">
        Password:
      </label>
        <input id="user_password" name="user[password]" size="30" type="password" />
      </li>

      <li class="file optional" id="form_file_input">
      <label for="form_file">
        File
      </label>
        <input id="form_file" name="form[file]" type="file" />
      </li>

      <li class="text required" id="book_description_input">
      <label for="book_description">
        Description<abbr title="required">*</abbr>
      </label>
        <textarea cols="40" id="book_description" name="book[description]" rows="20"></textarea>
      </li>

      <li class="boolean required" id="book_still_in_print_input">
      <label for="book_still_in_print">
	  Still in print<abbr title="required">*</abbr>
      </label>
	  <input name="book[still_in_print]" type="hidden" value="0" />
	  <input id="book_still_in_print" name="book[still_in_print]" type="checkbox" value="1" />
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

    context "with_hidden_field" do

      it "should find hidden field" do
	rendered.should have_form("/books", :post) do
	  with_hidden_field("authenticity_token")
	  self.should_receive(:have_tag).with('input', :with => { :name => 'authenticity_token', :type => 'hidden', :value => '718WaH76RAbIVhDlnOidgew62ikn8IUCOyWLEqjw1GE=' })
	  with_hidden_field("authenticity_token", '718WaH76RAbIVhDlnOidgew62ikn8IUCOyWLEqjw1GE=')
	end
      end

      it "should not find hidden field" do
	rendered.should have_form("/books", :post) do
	  without_hidden_field('user_id')
	  without_hidden_field('authenticity_token', 'blabla')
	end
      end

    end

    context "with_text_field" do

      it "should find text field" do
	rendered.should have_form("/books", :post) do
	  with_text_field('book[title]')
	  with_text_field('book[title]',nil)
	  with_text_field('book[author]','Authorname')
	end
      end

      it "should not find text field" do
	rendered.should have_form("/books", :post) do
	  without_text_field('book[title]','title does not exist')
	  without_text_field('book[authoRR]')
	  without_text_field('book[blabla]')
	end
      end

    end

    context "with_password_field" do

      it "should find password field" do
	rendered.should have_form("/books", :post) do
	  with_password_field('user[password]')
	end
      end

      it "should not find password field" do
	rendered.should have_form("/books", :post) do
	  without_password_field('account[password]')
	end
      end

    end

    context "with_file_field" do

      it "should find file field" do
	rendered.should have_form("/books", :post) do
	  with_file_field('form[file]')
	end
      end

      it "should not find file field" do
	rendered.should have_form("/books", :post) do
	  without_file_field('user[file]')
	end
      end

    end

    context "with_text_area" do

      it "should find text area" do
	rendered.should have_form("/books", :post) do
	  with_text_area('book[description]')
	end
      end

      it "should not find text area" do
	rendered.should have_form("/books", :post) do
	  without_text_area('user[bio]')
	end
      end

    end

    context "with_check_box" do

      it "should find check box" do
	rendered.should have_form("/books", :post) do
	  with_checkbox("book[still_in_print]")
	  with_checkbox("book[still_in_print]","1")
	end
      end

      it "should not find check box" do
	rendered.should have_form("/books", :post) do
	  without_checkbox("book[book]")
	  without_checkbox("book[still_in_print]","500")
	end
      end

    end

    context "with_radio_button" do

      it "should find radio button"
      it "should not find radio button"

    end

    context "with_submit" do

      it "should find submit"
      it "should not find submit"

    end

  end
end
