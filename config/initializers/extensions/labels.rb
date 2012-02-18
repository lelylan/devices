# This module enable a resource to be labeled

module Lelylan
  module Extensions
    module Labels

      # Add the before filter
      #def self.included(base)
        #base.append_before_filter :filter_labels, only: 'index'
      #end

      # Add the query to filter labels
      def filter_labels
        if params[:labels]
          params[:labels] = [params[:labels]] if !params[:labels].is_a?(Array)
          variable = instance_variable_get(variable_name)
          variable = variable.all_in(labels: params[:labels])
          instance_variable_set(variable_name, variable)
        end
      end

      private

        # Get the instance variable name
        def variable_name
          @variable_name ||= '@' + self.class.to_s.tableize.gsub('_controllers','').downcase
        end
    end
  end
end
