require "test_helper"

class UsersShowTest < ActionDispatch::IntegrationTest

  def setup
    @inactive_user  = users(:inactive)
    @activated_user = users(:archer)
  end

  test "有効化されていないユーザーはログインページにリダイレクト" do
    get user_path(@inactive_user)
    assert_response :redirect
    assert_redirected_to root_url
  end

  test "有効化されているユーザーはページを表示" do
    get user_path(@activated_user)
    assert_response :success
    assert_template "users/show"
  end
end
