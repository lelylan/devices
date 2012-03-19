module Lelylan
  module Errors
    module Helpers

      # ---------
      # Rescue
      # ---------

      def self.included(base)
        base.rescue_from Mongoid::Errors::DocumentNotFound, with: :document_not_found
        base.rescue_from BSON::InvalidObjectId, with: :bson_invalid_object_id
        base.rescue_from JSON::ParserError, with: :json_parse_error
        base.rescue_from Mongoid::Errors::InvalidType, with: :mongoid_errors_invalid_type
        base.rescue_from Lelylan::Errors::Time, with: :lelylan_errors_time
        base.rescue_from Lelylan::Type::Unauthorized, with: :lelylan_type_unauthorized
        base.rescue_from Lelylan::Type::NotFound, with: :lelylan_type_not_found
        base.rescue_from Lelylan::Type::InternalServerError, with: :lelylan_type_error
        base.rescue_from Lelylan::Type::ServiceUnavailable, with: :lelylan_type_service_unavailable
      end

      # Document not found
      def document_not_found
        render_404 "notifications.document.not_found", {id: params[:id]}
      end

      # Wrong ID for MongoDB
      def bson_invalid_object_id(e)
        render_404 "notifications.document.not_found", {id: params[:id]}
      end

      # Parsing error on JSON body
      def json_parse_error(e)
        render_422 "notifications.json.not_valid", parse_error(e)
      end
      
      # Assignation of wrong type to model field (e.g. hash instead of array)
      def mongoid_errors_invalid_type(e)
        render_422 "notifications.json.not_valid_type", parse_error(e)
      end

      def lelylan_errors_time(e)
        render_422 "notifications.query.time", e.message
      end

      # --------------------
      # Lelylan Type access
      # --------------------

      # 401 response
      def lelylan_type_unauthorized(e)
        code = "notifications.type.unauthorized"
        render_422 code, I18n.t(code)
      end

      # 404 response
      def lelylan_type_not_found(e)
        code = "notifications.type.not_found"
        render_422 code, I18n.t(code)
      end

      # 500 type service
      def lelylan_type_error(e)
        code = "notifications.type.error"
        render_422 code, I18n.t(code)
      end

      # 503 type service
      def lelylan_type_service_unavailable(e)
        code = "notifications.type.unavailable"
        render_422 code, I18n.t(code)
      end



      # --------
      # Views
      # --------

      # Not authorized
      def render_401
        render 'shared/401', status: 401 and return
      end

      # Not found
      def render_404(message, info)
        @error_code = message
        @message = I18n.t message
        @info = info.to_json
        render "shared/404", status: 404 and return
      end

      # Not valid
      def render_422(code, error)
        @body = clean_body
        @code = code
        @error = error.is_a?(String) ? error : error.full_messages.join('. ')
        render "shared/422", status: 422 and return
      end

  
      private 

        def parse_error(e)
          e.message.gsub("(right here) ------^\n", " ").
            gsub("'\n          ", " ").
            gsub("parse error: ", "").
            gsub(/ActiveSupport::HashWithIndifferentAccess/, "Hash").
            strip
        end

        def clean_body
          body = request.request_parameters
          # Hack to have a clean JSON. Not sure why, but it creates an hash where the 
          # key is the params and the value is null. With this cicle we clean it up.
          body.each_key {|key| body = JSON.parse key }
          return body
        end
    end
  end
end
