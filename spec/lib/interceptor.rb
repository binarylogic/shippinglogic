module HTTParty
  class Request
    def perform_actual_request
      response = http.request(@raw_request)
      if !FakeWeb.registered_uri?(:post, uri)
        File.open(File.dirname(__FILE__) + "/../responses/_new.xml", 'w') {|f| f.write(response.body) }
        raise FakeWeb::NetConnectNotAllowedError.new("You have not registered this response, the response has been put in responses/_new.xml")
      else
        response
      end
    end
  end
end