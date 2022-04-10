class Onboarding
  def self.chapters
    @chapters ||= {}
    lists = (ENV['geekos_trello_lists'] || '').split(',')
    lists.each do |listid|
      list = Trello::List.find(listid)
      @chapters[list.name] = list.cards
    end
    @chapters
  end
end
