module Crawler
  CRAWLERS = %i[
    ldap
    org_tree
  ].freeze

  class BaseCrawler
    def log
      Crawler.logger
    end

    def run
      log.info '-' * 10
      log.info "#{self.class.name} started crawling"
    end
  end

  class << self
    def list
      CRAWLERS.map { |x| "Crawler::#{x.to_s.classify}".constantize }
    end

    def run
      logger.info "#{self.class.name} started batch crawling"
      list.each { |klass| klass.new.run }
    end

    def logger
      return @logger if defined?(@logger)

      if Rails.env.test?
        @logger = Rails.logger
      else
        @logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
        @logger.formatter = Logger::Formatter.new
        @logger.level = :debug
      end
      @logger
    end
  end
end
