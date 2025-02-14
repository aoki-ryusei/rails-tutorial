require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "ログインしていない際に一覧ページにアクセスできないこと" do
    get users_path
    assert_redirected_to login_url
  end

  test "ログインしている際にfollowingページにアクセスできないこと" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end


  test "ログインしている際にfollowersページにアクセスできないこと" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
