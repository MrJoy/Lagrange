Given /^a widget$/ do
  @widget = Hash.new
end

When /^we twiddle it$/ do
  @widget.clear
end

Then /^it should be happy$/ do
  @widget.should be_a Hash
end
