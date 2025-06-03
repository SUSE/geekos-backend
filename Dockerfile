FROM ruby:3.4.4
ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT=development

RUN apt-get update
RUN apt-get install -y bsd-mailx vim less curl ldap-utils iputils-ping telnet ucspi-tcp-ipv6 netcat-traditional

COPY Gemfile* /geekos/
WORKDIR /geekos
RUN bundle install
ADD . /geekos

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s"]
