require 'rails_helper'

describe Crawler do
  describe '.list' do
    subject(:crawler) { described_class.list }

    it {
      expect(crawler).to eq [
        Crawler::Ldap,
        Crawler::Okta,
        Crawler::OrgTree
      ]
    }
  end

  describe '.run' do
    subject(:run) { described_class.run }

    it 'instantiates nested classes of a Crawler and run every single of them' do
      described_class.list.each do |klass|
        expect_any_instance_of(klass).to receive(:run).once
      end
      run
    end
  end

  describe '.logger' do
    subject(:logger) { described_class.logger }

    context 'production env' do
      before do
        allow(Rails.env).to receive(:test?).and_return(false)
        begin
          described_class.remove_instance_variable(:@logger)
        rescue NameError
          true
        end
      end

      it 'Would be turned to STDOUT' do
        expect(logger.instance_variable_get(:@logdev).dev).to eq $stdout
      end
    end
  end
end
