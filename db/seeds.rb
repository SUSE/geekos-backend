require 'oj'

tags = Oj.load_file((Rails.root.join 'tags.json').to_s).uniq

Rails.logger.silence do
  tags.each do |tag|
    Tag.create(name: tag)
  end
end
