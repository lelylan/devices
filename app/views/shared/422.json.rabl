object request

node(:status)  { |request| '422' }
node(:method)  { |request| request.method }
node(:request) { |request| request.url }

node(:error) do |request| 
  {
    code: @code,
    description: @error,
    body: @body
  }
end
