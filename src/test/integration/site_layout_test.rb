require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "Rootのレイアウト" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    get contact_path
    assert_select "title", full_title("Contact")
  end

  test "ログイン時のRootのレイアウト" do
    user = users(:michael)
    log_in_as(user)
    get root_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(user)
    assert_select "a[href=?]", edit_user_path(user)
    assert_select "a[href=?]", logout_path
  end
end
