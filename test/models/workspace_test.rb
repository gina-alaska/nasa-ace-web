# frozen_string_literal: true
require 'test_helper'

class WorkspaceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "to_s should return name" do
    workspace = Workspace.new(name: "Workspace Foo")
    assert_equal "Workspace Foo", workspace.to_s
  end
end
