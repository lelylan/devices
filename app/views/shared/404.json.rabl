object request

node(:status) { |request| '404' }
node(:request)  { |request| request.url  }

node(:error) do |request| 
  {
    code: 'notifications.resource.not_found',
    description: I18n.t('notifications.resource.not_found')
  }
end
