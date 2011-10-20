Given /^I have following template:$/ do |string|
  File.open($INDEX_HTML,'w+') do |file|
    file.write(string)
  end
end

When /^I open this template in browser$/ do
  visit('/index.html')
end

Then /^I should be able to match static content$/ do
  page.should have_content('Hello World!')
end

Then /^I should be able to match javascript generated content$/ do
  page.should have_content('Hello Another World!')
end
