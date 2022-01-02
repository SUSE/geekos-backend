module Crawler
  CRAWLERS = %i[
    ldap
    okta
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

    protected

    def deep_diff(a, b)
      (a.keys | b.keys).each_with_object({}) do |k, diff|
        if a[k] != b[k]
          diff[k] = a[k].is_a?(Hash) && b[k].is_a?(Hash) ? deep_diff(a[k], b[k]) : [a[k], b[k]]
        end
        diff
      end
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
