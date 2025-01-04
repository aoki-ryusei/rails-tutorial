require "test_helper"

class UserEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "編集に成功すること" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    # 無効な情報を送信する
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invalid",
                                              password: "foo",
                                              password_confirmation: "bar" } }
    # 編集画面に遷移すること
    assert_template 'users/edit'
    assert_select 'div.alert-danger'
  end

  test "編集に失敗すること" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: "",
                                              password_confirmation: "" } }
    # セッションにフラッシュメッセージがあること
    assert_not flash.empty?
    # 編集画面に遷移すること
    assert_redirected_to @user
    # reloadで最新情報をDBから取得
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test "ログインしていない場合は編集画面に遷移しないこと" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "ログインしていない場合は編集処理に失敗すること" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "Webからadmin権限が変更されないこと" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
                                    user: { password:              "password",
                                            password_confirmation: "password",
                                            admin: true } }
    assert_not @other_user.admin?
  end

  test "別のユーザーの編集画面に遷移しないこと" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "別のユーザーの編集処理に失敗すること" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "フレンドリーフォアーディングに成功すること" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

  test "ログインしていない際に削除処理にアクセスできないこと" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "管理者権限でなければ削除処理にアクセスできないこと" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end
end
