class Crawler::Fuze < Crawler::BaseCrawler
  # The API_SECRET is used as "Authorization" header for API requests to fuze
  # It should look like "Bearer ..."
  # You can obtain it by logging into https://web.fuze.com (with chromium)
  # and looking at the XHR request headers using you browser's devtools
  API_SECRET = ENV['geekos_fuze_secret']

  def run
    raise 'please set geekos_fuze_secret to run the fuze crawler' unless API_SECRET

    super
    crawl
  end

  def crawl
    mail2uid = {}
    log.info('FUZE -> Creating mail2uid map')
    LdapUser.all.each do |ldu|
      mail2uid[ldu.mail.downcase] = ldu.uid
    end
    url = 'https://api.fuze.com/contactive/v1.0/users/me/contacts'
    offset = -1
    loop do
      params = { sortField: 'revision', sortOrder: 'asc', limit: '100',
                 offset: [offset, 0].max }
      json = Oj.load(RestClient.get(url, { params: params, Authorization: API_SECRET }).body, symbol_keys: true)
      contact_list = json[:data][:items].map { |i| i.slice(:email, :phone) }
      contact_list.select { |c| c[:email].present? }.each do |contact|
        mail = contact[:email][0][:email]
        next unless mail2uid[mail.downcase] && contact[:phone][0]

        local_user = User.find(mail2uid[mail.downcase]).local_user
        next if local_user.phone

        phone = contact[:phone][0][:original]
        cc = contact[:phone][0][:countryCode]
        phone.gsub!("+#{cc}", "+#{cc} ")
        phone.gsub!('+49 911', '+49 911 ')
        phone.gsub!('+49 911 7405', '+49 911 7405 ')
        phone.gsub!('+49 911 880', '+49 911 880 ')
        phone.gsub!(/^\+1 ([0-9]{3})/, '+1 \\1 ')
        log.info("FUZE -> Setting '#{mail2uid[mail.downcase]}' phone to: #{phone}")
        local_user.update!(phone: phone)
      end
      break if json[:data][:items].length < 100

      offset += 100
    end
  end
end
