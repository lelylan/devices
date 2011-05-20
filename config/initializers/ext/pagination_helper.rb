module Lelylan
  module Pagination
    module Helpers

      # Redirect when the page or per params are missing and
      # check the *all* option that show all owned resources
      def set_pagination
        page, per = normalize_pagination_params
        if (page != params[:page] or per != params[:per])
          redirect_to action: :index, page: page, per: per and return
        end
        paginate_navigation
      end

      def normalize_pagination_params
        page = params[:page] ? params[:page] : Settings.pagination.page
        per = params[:per] ? params[:per] : Settings.pagination.per
        if (per == "all")
          page = Settings.pagination.page
          per = resources_count
        end
        [page, per]
      end

      # Populate the links for the navigation between the resources
      def paginate_navigation
        @last_uri  = page_url_for(last_page)
        @next_uri  = page_url_for(next_page(@last_page))
        @prev_uri  = page_url_for(prev_page(@last_page))
        @first_uri = page_url_for(first_page)
      end

      def last_page
        last = resources_count / params[:per].to_f
        last = Settings.pagination.page if last == 0
        @last_page = last.ceil.to_s
      end

      def next_page(last)
        nexty = params[:page].to_i + 1
        page = (nexty <= last.to_i) ? nexty.to_s : last
      end

      def prev_page(last)
        previous = params[:page].to_i - 1
        page = (previous > 1) ? previous.to_s : Settings.pagination.page
        page = (previous > last.to_i) ? last : page
      end

      def first_page
        Settings.pagination.page
      end

      def page_url_for(page)
        query_string = request.query_string.gsub(/page=(\d*)/, "page=#{page}")
        host = "#{request.protocol}#{request.host_with_port}/#{model_klass.to_s.downcase.pluralize}?#{query_string}"
        return host
      end


      # Shared helpers      
      def resources_count
        klass = model_klass
        klass.where(created_from: current_user.uri).count
      end

      def model_klass
        self.class.to_s.gsub("Controller", "").singularize.constantize
      end

    end
  end
end
