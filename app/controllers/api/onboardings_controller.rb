class Api::OnboardingsController < Api::BaseController
  def show
    render json: Rails.cache.fetch('onboarding_trello', expires_in: 2.hours) {
                   Onboarding.chapters.to_json
                 }, status: :ok, cached: true
  end
end
