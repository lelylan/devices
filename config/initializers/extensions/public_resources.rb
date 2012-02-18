module Lelylan
  module Resources
    module Public
      def self.included(base)
        base.send(:helper_method, :public_resource)
      end

      def allow_public_resources(*resources)
        if resources.include?(params[:controller])
          if %w(index show).include?(params[:action])
            @public_resource = true
          end
        end
      end

      def accessing_public_resource?
        @public_resource
      end
    end
  end
end
