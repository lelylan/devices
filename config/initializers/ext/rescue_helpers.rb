module Lelylan
  module Rescue
    module Helpers

      def self.included(base)
        base.rescue_from Mongoid::Errors::Validations, with: :validation_errors
        base.rescue_from Mongoid::Errors::DocumentNotFound, with: :document_not_found
        base.rescue_from BSON::InvalidObjectId, with: :bson_invalid_object_id
        base.rescue_from JSON::ParserError, with: :json_parse_error
        base.rescue_from Mongoid::Errors::InvalidType, with: :mongoid_errors_invalid_type
        base.rescue_from WillPaginate::InvalidPage, with: :will_paginate_invalid_page
        base.rescue_from ZeroDivisionError, with: :zero_division_error
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

      # Invalid page (e.g. a string instead of a number)
      def will_paginate_invalid_page(e)
        render_422 "notifications.pagination.not_valid_page", {page: params[:page]}
      end

      # Invalid per page (e.g. a string instead of a number)
      def zero_division_error(e)
        render_422 "notifications.pagination.not_valid_per", {per: params[:per]}
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
