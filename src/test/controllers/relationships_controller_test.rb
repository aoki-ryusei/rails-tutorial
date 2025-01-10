require "test_helper"

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  test "ログインしていない場合、フォロー処理が行われない" do
    assert_no_difference 'Relationship.count' do
      post relationships_path
    end
    assert_redirected_to login_url
  end

  test "ログインしていない場合、フォロー解除処理が行われない" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end
end
