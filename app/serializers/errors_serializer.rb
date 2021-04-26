class ErrorsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :message
end
