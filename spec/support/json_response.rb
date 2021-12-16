def json_response
  Hashie::Mash.new(Oj.load(response.body, symbolize_names: true))
end
