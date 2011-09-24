require 'spec_helper'

describe "have_form" do

  let(:rendered) do
    <<HTML
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

      <li class="email optional" id="user_email_input">
      <label for="user_email">
        E-mail address:
      </label>
        <input id="user_email" name="user[email]" size="30" type="email" value="email@example.com" />
      </li>

      <li class="email_confirmation optional" id="user_email_confirmation_input">
      <label for="user_email_confirmation">
        E-mail address confirmation:
      </label>
        <input id="user_email_confirmation" name="user[email_confirmation]" size="30" type="email" />
      </li>

      <li class="url optional" id="user_url_input">
      <label for="user_url">
        E-mail address:
      </label>
        <input id="user_url" name="user[url]" size="30" type="url" value="http://user.com" />
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
      <li class="number required">
      <label for="book_number">
	  Still in print<abbr title="required">*</abbr>
      </label>
	  <input name="number" type="number" />
	  <input name="number_defined" type="number" value="3" />
      </li>

      <li class="range required">
      <label for="range">
	  Still in print<abbr title="required">*</abbr>
      </label>
	  <input name="range1" type="range" min="1" max="3" />
	  <input name="range2" type="range" min="1" max="3" value="2" />
      </li>

      <li class="date required">
      <label for="date">
	  Something<abbr title="required">*</abbr>
      </label>
	  <input name="book_date" type="date" />
	  <input name="book_month" type="month" value="5" />
	  <input name="book_week" type="week" />
	  <input name="book_time" type="time" />
	  <input name="book_datetime" type="datetime" />
	  <input name="book_datetime_local" type="datetime-local" />
      </li>

      <li class="radio required" id="form_name_input">
        <fieldset>
	<legend class="label">
	<label>Name<abbr title="required">*</abbr></label>
	</legend>
	  <ol>
	    <li class="name_true">
	    <label for="form_name_true">
	      <input id="form_name_true" name="form[name]" type="radio" value="true" /> Yes
	    </label>
	    </li>
	    <li class="name_false">
	    <label for="form_name_false">
	      <input id="form_name_false" name="form[name]" type="radio" value="false" /> No</label>
	    </li>
	  </ol>
	</fieldset>
      </li>

    </ol>
  </fieldset>

  <fieldset class="buttons">
    <ol>
    <li class="commit">
      <input class="create" id="book_submit" name="commit" type="submit" value="Create Book" />
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
          self.should_receive(:have_tag).with('input', :with => {
            :name => 'authenticity_token',
            :type => 'hidden',
            :value => '718WaH76RAbIVhDlnOidgew62ikn8IUCOyWLEqjw1GE='
          })
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

    context "with_email_field" do
      it "should find email field" do
        rendered.should have_form("/books", :post) do
          with_email_field('user[email]')
          with_email_field('user[email]', 'email@example.com')
          with_email_field('user[email_confirmation]', nil)
        end
      end

      it "should not find email field" do
        rendered.should have_form("/books", :post) do
          without_email_field('book[author]','Authorname')
          without_email_field('user[emaiL]')
          without_email_field('user[apocalyptiq]')
        end
      end
    end

    context "with_url_field" do
      it "should find url field" do
        rendered.should have_form("/books", :post) do
          with_url_field('user[url]')
          with_url_field('user[url]', 'http://user.com')
        end
      end

      it "should not find url field" do
        rendered.should have_form("/books", :post) do
          without_url_field('user[url]','Authorname')
          without_url_field('user[emaiL]')
          without_url_field('user[apocalyptiq]')
        end
      end
    end

    context "with_number_field" do
      it "should find number field" do
        rendered.should have_form("/books", :post) do
          with_number_field('number')
          with_number_field('number_defined', 3)
          with_number_field('number_defined', '3')
        end
      end

      it "should not find number field" do
        rendered.should have_form("/books", :post) do
          without_number_field('number',400)
          without_number_field('number','400')
          without_number_field('user[emaiL]')
          without_number_field('user[apocalyptiq]')
        end
      end
    end

    context "with_range_field" do
      it "should find range field" do
        rendered.should have_form("/books", :post) do
          with_range_field('range1', 1, 3)
          with_range_field('range1','1','3')
          with_range_field('range2', 1, 3, :with => { :value => 2 } )
          with_range_field('range2', 1, 3, :with => { :value => '2' } )
        end
      end

      it "should not find range field" do
        rendered.should have_form("/books", :post) do
          without_range_field('number')
          without_range_field('range1', 1, 5)
          without_range_field('range2', 1, 3, :with => { :value => 5 } )
        end
      end
    end

    context "with_date_field" do
      it "should find date field" do
        rendered.should have_form("/books", :post) do
          with_date_field(:date)
          with_date_field(:date, 'book_date')
          with_date_field(:month, 'book_month', :with => { :value => 5 })
          with_date_field(:week,'book_week')
          with_date_field(:time, 'book_time')
          with_date_field(:datetime, 'book_datetime')
          with_date_field('datetime-local', 'book_datetime_local')
        end
      end

      it "should not find date field" do
        rendered.should have_form("/books", :post) do
          without_date_field(:date, 'book_something')
          without_date_field(:month, 'book_month', :with => { :value => 100500 })
        end
      end

      it "should raise exception if wrong date field type specified" do
        expect do
          rendered.should have_form("/books", :post) do
            without_date_field(:unknown, 'book_something')
          end
        end.to raise_error('unknown type `unknown` for date picker')
        expect do
          rendered.should have_form("/books", :post) do
            with_date_field(:unknown, 'book_something')
          end
        end.to raise_error('unknown type `unknown` for date picker')
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
      it "should find radio button" do
        rendered.should have_form("/books", :post) do
          with_radio_button("form[name]","true")
        end
      end

      it "should not find radio button" do
        rendered.should have_form("/books", :post) do
          without_radio_button("form[name]","100500")
          without_radio_button("form[item]","false")
        end
      end
    end

    context "with_submit" do
      it "should find submit" do
      rendered.should have_form("/books", :post) do
        with_submit("Create Book")
      end
      end

      it "should not find submit" do
        rendered.should have_form("/books", :post) do
          without_submit("Destroy Book")
        end
      end
    end

  end
end
