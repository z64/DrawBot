module DrawBot
  class ErrorHandler < Discord::Middleware
    alias Rescue = Tuple(Exception.class, String)

    def initialize(@unhandled_response : String?, *@rescues : Rescue)
    end

    def call(context, done)
      done.call
    rescue ex
      @rescues.each do |exception, response|
        if ex.class == exception
          context.client.create_message(
            context.payload.channel_id,
            response.gsub("%message%", ex.message)
          )
          return
        end
      end

      if response = @unhandled_response
        context.client.create_message(
          context.payload.channel_id,
          response.gsub("%message%", ex.message)
        )
      end

      raise ex
    end
  end
end
