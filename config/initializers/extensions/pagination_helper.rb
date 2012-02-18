module Lelylan
  module Pagination
    module Helpers
      def self.included(base)
        base.class_eval do
          helper_method :first_page_uri
          helper_method :prev_page_uri
          helper_method :next_page_uri
          helper_method :last_page_uri
        end
      end

      # Fill default values to :page and :per params when missing
      # and redirect to the correct page with pagination params
      def paginate
        set_pagination(params[:page], params[:per])
      end

      # Get the first page uri
      def first_page_uri
        page_uri_for(@first_page)
      end

      # Get the previous page uri
      def prev_page_uri
        page_uri_for(@prev_page)
      end

      # Get the next page uri
      def next_page_uri
        page_uri_for(@next_page)
      end

      # Get the last page uri
      def last_page_uri
        page_uri_for(@last_page)
      end


      private 

        # Redirect to the correct page if params are missing, otherwise populate
        # all variables used to define the navigation links.
        def set_pagination(page, per)
          new_page, new_per = normalize_pagination_params(page, per)
          if (new_page != page or new_per != per)
            redirect_to(cleaned_uri(new_page,new_per))
          else
            create_navigation_links(page, per)
          end
        end

        # Get the cleaned request querystring
        def cleaned_uri(page, per)
          query_string = params.except('format', 'action', 'controller', 'device_id').merge(page: page, per: per)
          host = "#{request.protocol}#{request.host_with_port}#{request.path}?#{query_string.to_query}"
        end

        # Get default page values.
        def normalize_pagination_params(page, per)
          new_page = page ? page : Settings.pagination.page
          new_per  = per ? per : Settings.pagination.per
          new_page = Settings.pagination.page  if per == 'all'
          new_per  = total_number_of_resources if per == 'all'
          return [new_page, new_per]
        end


        # Find the page numbers for the navigation
        def create_navigation_links(page, per)
          @last_page  = find_last_page(page, per)
          @next_page  = find_next_page(page, per, @last_page)
          @prev_page  = find_prev_page(page, per, @last_page)
          @first_page = find_first_page(page, per)
        end

        # Find last page
        def find_last_page(page, per)
          last = total_number_of_resources / per.to_f
          last = Settings.pagination.page if last == 0
          last.ceil.to_s
        end

        # Find next page
        def find_next_page(page, per, last)
          nexty = page.to_i + 1
          (nexty <= last.to_i) ? nexty.to_s : last
        end

        # Find previous page
        def find_prev_page(page, per, last)
          previous = page.to_i - 1
          page = (previous > 1) ? previous.to_s : Settings.pagination.page
          (previous > last.to_i) ? last : page
        end

        # Find first page
        def find_first_page(page, per)
          Settings.pagination.page
        end

        # Create the paginated URI
        def page_uri_for(page)
          query_string = request.query_string.gsub(/page=(\d*)/, "page=#{page}")
          host = "#{request.protocol}#{request.host_with_port}#{request.path}?#{query_string}"
        end

        # Returns the number of owned resources 
        def total_number_of_resources
          klass = model_klass
          accessing_public_resource? ? klass.where(public: true).count : klass.where(created_from: current_user.uri).count
        end

        # Return the 'supposed' model name
        def model_klass
          self.class.to_s.gsub("Controller", "").singularize.constantize
        end
    end
  end
end

