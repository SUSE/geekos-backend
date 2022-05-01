class Onboarding
  def self.chapters
    @chapters ||= {}
    lists = (ENV.fetch('geekos_trello_lists', nil) || '').split(',')
    lists.each do |listid|
      list = Trello::List.find(listid)
      @chapters[list.name] = list.cards
    end
    @chapters
  end
end
