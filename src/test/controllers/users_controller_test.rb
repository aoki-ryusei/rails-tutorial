require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "ログインしていない際に一覧ページにアクセスできないこと" do
    get users_path
    assert_redirected_to login_url
  end
end
