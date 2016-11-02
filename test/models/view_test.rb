require 'test_helper'

class ViewTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "to_s should return name" do
    view = View.new(name: "View Foo")
    assert_equal "View Foo", view.to_s
  end
end