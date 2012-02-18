module Lelylan
  module Rescue
    module Helpers

      def self.included(base)
        base.rescue_from Mongoid::Errors::Validations, with: :validation_errors
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

      # Document not valid
      def validation_errors(e)
        render_422 "notifications.document.not_valid", e.message
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

      # 401 type service 
      def lelylan_type_unauthorized(e)
        render_422 "notifications.type.unauthorized", e.message.meta.request
      end

      # 404 type service
      def lelylan_type_not_found(e)
        render_422 "notifications.type.not_found", e.message.meta.request
      end

      # 500 type service
      def lelylan_type_error(e)
        render_422 "notifications.type.error", e.message.error.info
      end

      # 503 type service
      def lelylan_type_service_unavailable(e)
        render_422 "notifications.type.unavailable", e.message.error.info
      end
  
      private 

        def parse_error(e)
          e.message.gsub("(right here) ------^\n", " ").
            gsub("'\n          ", " ").
            gsub("parse error: ", "").
            gsub(/ActiveSupport::HashWithIndifferentAccess/, "Hash").
            strip
        end
    end
  end
end
