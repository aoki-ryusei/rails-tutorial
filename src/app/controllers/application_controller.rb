class ApplicationController < ActionController::Base
  include SessionsHelper

  private
    # ログイン済みのユーザーかチェックを行う
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください"
        redirect_to login_url, status: :see_other
      end
    end
end
