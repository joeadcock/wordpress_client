module WordpressClient
  # Base class for all errors emitted from this gem. Rescue this in order to
  # catch everything.
  #
  # See the list of subclasses for more specific error types.
  class Error < ::StandardError; end

  # Raised when the clients attempt to do something that the user isn't
  # authorized to do.
  #
  # This could happen if you try to delete a post and the user only has
  # read-only access, for example.
  # It would also happen if you provide bad authentication details.
  #
  # @see Error
  class UnauthorizedError < Error; end

  # Raised when a request times out.
  #
  # @see Error
  class TimeoutError < Error; end

  # Raised when the server had an error, or when the server returned something
  # unexpected, despite saying everything went okay. It's the most generic
  # "Something went wrong with the request" error.
  #
  # @see Error
  class ServerError < Error; end

  # Raised when trying to find a resource that doesn't exist. It will also
  # happen when you try to update a resource that doesn't exist.
  #
  # Lack of authorization can also mask actual resources so it appears that
  # they don't exist.
  #
  # @see Error
  class NotFoundError < Error; end

  # Raised when the server rejects the body of a request. The error message
  # will often include information about why the body was rejected, but it is
  # not guaranteed.
  #
  # @see Error
  class ValidationError < Error; end
end
