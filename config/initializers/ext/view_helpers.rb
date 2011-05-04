module Lelylan
  module View
    module Helpers
      # Not Found view
      def render_404(message, info)
        @error_code = message
        @message = I18n.t message
        @info = info.to_json
        render "shared/404", status: 404 and return
      end

      # Error view
      def render_422(message, info)
        @error_code = message
        @message = I18n.t message
        @info = info
        render "shared/422", status: 422 and return
      end
    end
  end
end
