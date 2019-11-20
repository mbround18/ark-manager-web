class AgentAccess
    def incoming(message, callback)
        puts message
    #   # Let non-subscribe messages through
    #   unless message['channel'] == '/meta/subscribe'
    #     return callback.call(message)
    #   end
  
      # Get subscribed channel and auth token
    #   subscription = message['subscription']
    #   msg_token    = message['ext'] && message['ext']['authToken']
  
      # Find the right token for the channel
    #   @file_content ||= File.read('./tokens.json')
  
    #   registry = JSON.parse(@file_content)
    #   token    = registry[subscription]
  
    #   # Add an error if the tokens don't match
    #   if token != msg_token
    #     message['error'] = 'Invalid subscription auth token'
    #   end
  
      # Call the server back now we're done
      callback.call(message)
    end
  end
  