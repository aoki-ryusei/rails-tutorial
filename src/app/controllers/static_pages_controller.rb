class StaticPagesController < ApplicationController
  def home
    @title = __method__.capitalize
  end

  def help
    @title = __method__.capitalize
  end

  def about
    @title = __method__.capitalize
  end
end
