# Download user pictures from Delve: https://eur.delve.office.com/
# Image path is for example: /mt/v3/people/profileimage?userId=tschmidt%40suse.com&size=L
# Update a single picture with the one from Delve:
# `Crawler::Delve::RemotePicture.new(User.find('tschmidt')).download!`
class Crawler::Delve < Crawler::BaseCrawler
  def run
    super
    users = User.all
    users.each_with_index do |user, index|
      log.info "User ##{index + 1}/#{users.count}: #{user.username}"
      RemotePicture.new(user).download! unless user.img
    end
  end

  class RemotePicture
    attr_accessor :user

    def initialize(user)
      @user = user
    end

    def download!
      Crawler.logger.info "Downloading #{delve_image_url}"
      if !remote_data
        Crawler.logger.debug "No user image found in Delve ...skip"
      elsif same_image?
        Crawler.logger.debug "Same image stored locally as in Delve ...skip"
      else
        handle_filename_and_save
      end
    end

    # needed cookies: X-Delve-AuthEurS
    def remote_data
      @remote_data ||= RestClient.get(delve_image_url,
                                      { cookies: { "X-Delve-AuthEurS" => ENV['delve_auth_cookie'] } }).body
    rescue StandardError
      nil
    end

    def same_image?
      return false unless user.img && remote_data

      Digest::SHA256.digest(user.img.data) ==
        Digest::SHA256.digest(remote_data)
    end

    private

    def delve_image_url
      "https://eur.delve.office.com/mt/v3/people/profileimage?userId=#{user.email}&size=L"
    end

    def handle_filename_and_save
      user.img = remote_data
      user.img.name = "delve.#{user.employeenumber}.#{user.img.format}"
      user.save!
    end
  end
end
