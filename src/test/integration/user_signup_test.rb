require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
end

# ユーザー登録処理周りのテスト
class UsersSignupTest < UsersSignup

  test "不正なログイン情報" do
    get signup_path
    # ユーザーが増えていないこと
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                          email: "user@invalid",
                                          password:              "foo",
                                          password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert.alert-danger'
  end

  test "正常なログイン情報" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                          email: "user@example.com",
                                          password:              "password",
                                          password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end

# アカウント有効化処理周りのテスト
class AccountActivationsTest < UsersSignup
  def setup
    super
    post users_path, params: { user: { name:  "Example User",
                                        email: "user@example.com",
                                        password:              "password",
                                        password_confirmation: "password" } }
    @user = assigns(:user)
  end

  test "有有効化されていないこと" do
    assert_not @user.activated?
  end

  test "アカウント有効か前にログインできないこと" do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  test "不正な有効化トークンで有効化できないこと" do
    get edit_account_activation_path("invalid token", email: @user.email)
    assert_not is_logged_in?
  end

  test "不正なメールアドレスで有効化できないこと" do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not is_logged_in?
  end

  test "アカウントの有効化に成功すること" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
