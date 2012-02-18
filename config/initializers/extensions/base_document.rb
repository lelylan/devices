module Lelylan
  module Document
    module Base
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Initialize the model adding resource and creator URI
        def base(params, request, current_user)
          resource = self.new(params)
          resource.created_from = current_user.uri
          resource.uri  = self.base_uri(request, resource)
          return resource
        end
        # Create the resource URI
        def base_uri(request, resource)
          protocol = request.protocol
          host     = request.host_with_port
          name     = resource.class.name.underscore.pluralize
          id       = resource.id.as_json
          uri      = protocol + host + "/" + name + "/" +  id
        end
      end
    end
  end
end
