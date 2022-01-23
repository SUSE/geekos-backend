# frozen_string_literal: true

module Graphql
  # base class of all GraphqlControllers
  class UsersController < GraphqlApplicationController
    model('User')

    action(:show).permit(:ident!).returns_single

    def show
      user = User.find(params[:ident])
    end

  end
end
