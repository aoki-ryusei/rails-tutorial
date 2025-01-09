require "test_helper"

class MicropostsInterface < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    log_in_as(@user)
  end
end

class MicropostsInterfaceTest < MicropostsInterface

  test "ページネーション実装" do
    get root_path
    assert_select 'div.pagination'
  end

  test "無効な送信に対してマイクロポストは作成されないこと" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'  # 正しいページネーションリンク
  end

  test "有効な送信に対してマイクロポストは作成されること" do
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  test "profile pageに削除ボタンが表示される" do
    get user_path(@user)
    assert_select 'a', text: 'delete'
  end

  test "マイクロポストが削除される" do
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  test "他の人のprofile pageに削除ボタンが表示されない" do
    get user_path(users(:archer))
    assert_select 'a', { text: 'delete', count: 0 }
  end
end

class MicropostSidebarTest < MicropostsInterface

  test "正しいマイクロポスト数を表示" do
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
  end

  test "マイクロポストがない場合" do
    log_in_as(users(:malory))
    get root_path
    assert_match "0 microposts", response.body
  end

  test "単数形のmicropostが表示される" do
    log_in_as(users(:lana))
    get root_path
    assert_match "1 micropost", response.body
  end
end
