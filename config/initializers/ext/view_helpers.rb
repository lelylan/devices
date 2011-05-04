module Lelylan
  module View
    module Helpers
      # Not Found view
      def render_404(message, info)
        @message = I18n.t message
        @info    = info.to_s
        render "shared/404", status: 404 and return
      end

      # Error view
      def render_422(message, info)
        @message = I18n.t message
        @info    = info.to_json
        render "shared/422", status: 422 and return
      end
    end
  end
end
