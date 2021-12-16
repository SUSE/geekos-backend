class Onboarding
  LISTS = (ENV['geekos_trello_lists'] || '').split(',')

  def self.chapters
    @chapters ||= {}
    LISTS.each do |listid|
      list = Trello::List.find(listid)
      @chapters[list.name] = list.cards
    end
    @chapters
  end
end
