require "test_helper"

class Following < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end
end

class FollowPageTest < Following

  test "フォローページ" do
    get following_user_path(@user)
    assert_response :success
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "フォロワーページ" do
    get followers_user_path(@user)
    assert_response :success
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "ホームページのfeed" do
    get root_path
    @user.feed.paginate(page: 1).each do |micropost|
      assert_match CGI.escapeHTML(micropost.content), response.body
    end
  end
end

class FollowTest < Following

  test "標準方法でフォローをする" do
    assert_difference "@user.following.count", 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
    assert_redirected_to @other
  end

  test "Hotwireでのフォローをする" do
    assert_difference "@user.following.count", 1 do
      post relationships_path(format: :turbo_stream),
            params: { followed_id: @other.id }
    end
  end
end

class Unfollow < Following

  def setup
    super
    @user.follow(@other)
    @relationship = @user.active_relationships.find_by(followed_id: @other.id)
  end
end

class UnfollowTest < Unfollow

  test "標準方法でフォローを解除" do
    assert_difference "@user.following.count", -1 do
      delete relationship_path(@relationship)
    end
    assert_response :see_other
    assert_redirected_to @other
  end

  test "Hotwireでのフォローを解除" do
    assert_difference "@user.following.count", -1 do
      delete relationship_path(@relationship, format: :turbo_stream)
    end
  end
end
