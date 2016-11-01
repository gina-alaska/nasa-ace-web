# frozen_string_literal: true
class ApplicationHelperTest < ActionView::TestCase
  test "ckan_url should return a contact path" do
    assert_equal "http://ace.gina.alaska.edu/group", ckan_url('group')
  end

  test "ckan_url should return ckan_url" do
    assert_equal "http://ace.gina.alaska.edu", ckan_url
  end
end
