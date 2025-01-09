require "test_helper"

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "有効なmicropost" do
    assert @micropost.valid?
  end

  test "ユーザーIDは必須" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "contentは必須" do
    @micropost.content = "    "
    assert_not @micropost.valid?
  end

  test "contentは140文字以内" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "順序が最新のものが先にくる" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
