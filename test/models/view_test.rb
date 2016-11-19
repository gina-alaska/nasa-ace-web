# frozen_string_literal: true
require 'test_helper'

class ViewTest < ActiveSupport::TestCase
  setup do
    @workspace = workspaces(:one)
    @view = views(:one)
  end

  test "to_s should return name" do
    view = View.new(name: "View Foo")

    assert_equal "View Foo", view.to_s
  end

  test "duplicate should return new view" do

    assert_difference('@workspace.views.count') do
      new_view = @view.duplicate(@workspace)
      assert_equal "View1-duplicate", new_view.to_s
    end
  end
end
