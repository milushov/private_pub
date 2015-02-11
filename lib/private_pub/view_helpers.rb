require 'pry'
module PrivatePub
  module ViewHelpers
    # Publish the given data or block to the client by sending
    # a Net::HTTP POST request to the Faye server. If a block
    # or string is passed in, it is evaluated as JavaScript
    # on the client. Otherwise it will be converted to JSON
    # for use in a JavaScript callback.
    def publish_to(channel, data = nil, &block)
      code = capture(&block)

      begin
        compiled_code = CoffeeScript.compile(code)
      rescue Exception => e
        puts "\n\n compile coffee error: #{e.message} \n\n" 
        # seems to be it's not coffee, so leave this as before
        compiled_code = code
      end

      PrivatePub.publish_to(channel, data || compiled_code)
    end

    # Subscribe the client to the given channel. This generates
    # some JavaScript calling PrivatePub.sign with the subscription
    # options.
    def subscribe_to(channel)
      subscription = PrivatePub.subscription(:channel => channel)
      content_tag "script", :type => "text/javascript" do
        raw("PrivatePub.sign(#{subscription.to_json});")
      end
    end
  end
end
