require "test_helper"

class PasswordResets < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    # @user を定義する
    @user = users(:michael)
  end
end

class ForgotPasswordFormTest < PasswordResets

  test "パスワードリセット画面に遷移すること" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name= ?]', 'password_reset[email]'
  end

  test "不正なメールアドレスを入力した際のテスト" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end
end

class PasswordResetForm < PasswordResets

  def setup
    super
    post password_resets_path,
          params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end

class PasswordFormTest < PasswordResetForm

  test "有効なメールアドレスでパスワード再設定のメールを送信" do
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "無効なメールアドレスでパスワード再設定にアクセス" do
    get edit_password_reset_path(@reset_user.reset_token, email: "")
    assert_redirected_to root_url
  end

  test "無効なトークンでパスワード再設定にアクセス" do
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "正しいメールアドレス、トークンでパスワード再設定にアクセス" do
    get edit_password_reset_path(@reset_user.reset_token,
                                  email: @reset_user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  end
end

class PasswordUpdateTest < PasswordResetForm

  test "誤ったパスワードでの更新" do
    patch password_reset_path(@reset_user.reset_token),
    params: { email: @reset_user.email,
              user: { password:              "foobaz",
                      password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
  end

  test "空のパスワードでの更新" do
    patch password_reset_path(@reset_user.reset_token),
    params: { email: @reset_user.email,
              user: { password:              "",
                      password_confirmation: "" } }
    assert_select 'div#error_explanation'
  end

  test "有効なパスワードでの更新" do
    patch password_reset_path(@reset_user.reset_token),
    params: { email: @reset_user.email,
              user: { password:              "foobaz",
                      password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_nil @reset_user.reload.reset_digest
    assert_not flash.empty?
    assert_redirected_to @user
  end
end

class ExpiredToken < PasswordResets

  def setup
    super
    # パスワードリセットのトークンを作成する
    post password_resets_path,
          params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
    # トークンを手動で失効させる
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    # ユーザーのパスワードの更新を試みる
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
  end
end

class ExpiredTokenTest < ExpiredToken

  test "パスワードリセットページにリダイレクト" do
    assert_redirected_to new_password_reset_url
  end

  test "パスワードリセットページに‘期限切れ‘のメッセージが表示" do
    follow_redirect!
    assert_match /パスワードリセットの有効期限が切れました/i, response.body
  end
end
