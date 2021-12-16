class Crawler::Picture < Crawler::BaseCrawler
  def run
    super
    users = User.all
    log.info "#{local_users.count} users found"
    users.each_with_index do |user, index|
      log.info "Picture for User ##{index + 1} from #{users.count}: Processing employeenumber: #{user.employeenumber}"
      RemotePicture.new(user).download! if user.image_url
    end
  end

  class RemotePicture
    attr_accessor :user

    def initialize(user)
      @user = user
    end

    def download!
      if same_image?
        Crawler.logger.debug "Same image stored locally as -> #{user.image_url}"
        Crawler.logger.debug '...skip'
      else
        Crawler.logger.info "Downloading #{user.image_url}"
        handle_filename_and_save
      end
    end

    # set ENV['cookie-session-name'] + ENV['cookie-session-value'] to gain access to intra.microfocus.net images
    # cookie-session-name looks like 'IPCZQX039ba80e44', get it from a browser session
    def remote_data
      cookies = (ENV['cookie-session-name'] ? { ENV['cookie-session-name'] => ENV['cookie-session-value'] } : {})
      @remote_data ||= RestClient.get(local_user.image_url, { cookies: cookies }).body
    rescue RestClient::NotFound
      nil
    end

    def same_image?
      return false unless user.img && remote_data

      Digest::SHA256.digest(user.img.data) ==
        Digest::SHA256.digest(remote_data)
    end

    private

    def handle_filename_and_save
      user.img = remote_data
      if user.img
        tmp_binary = user.img.data
        user.img = nil
        # TODO: Yes ;) we need to remove file first to make sure we can rename it. Limitation of Dragonfly
        user.save!
        user.img = tmp_binary
        user.img.name = "#{user.employeenumber}.#{user.img.format}"
      end
      user.save!
    end
  end
end
