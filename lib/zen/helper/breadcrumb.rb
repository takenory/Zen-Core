#:nodoc:
module Ramaze
  #:nodoc:
  module Helper
    ##
    # Helper that can be used to quickly generate breadcrumbs without having
    # to manually write the HTML separators and formatting the output correctly.
    # In order to create a set of breadcrumbs we first need to call the
    # set_breadcrumbs method:
    #
    #     set_breadcrumbs(segment1, segment2, segment3, etc)
    #
    # Each argument will be a segment of the breadcrumbs, separated by a custom
    # character. Retrieving the breadcrumbs is super easy:
    #
    #     get_breadcrumbs
    #
    # This will generate the correct HTML and return it, all you have to do is
    # output it.
    #
    # @since  0.1
    #
    module Breadcrumb
      ##
      # Appends each element to the list of breadcrumb segments.
      #
      # @example
      #  set_breadcrumbs "Articles", "Edit"
      #
      # Note that you'll have to manually specify anchor tags, this method won't
      # automatically generate URLs.
      #
      # @param  [Array] args Array of segments for the breadcrumbs.
      # @since  0.1
      #
      def set_breadcrumbs(*args)
        @breadcrumbs = args
      end

      ##
      # Retrieves all breadcrumbs and separates them either by "&raquo;" or a
      # custom element set as the first argument of this method.
      #
      # @example
      #  get_breadcrumbs # => "Articles &raquo; Edit"
      #
      # @example
      #  get_breadcrumbs ">" # => "Articles > Edit"
      #
      # @param  [String] separator The HTML character to use for separating each
      #  segment.
      # @return [String]
      #
      def get_breadcrumbs(separator = '/')
        if !@breadcrumbs or @breadcrumbs.empty?
          return
        end

        items     = @breadcrumbs.dup
        items[-1] = '<span class="current">%s</span>' % items[-1]

        return items.join(' %s ' % separator)
      end
    end # Breadcrumb
  end # Helper
end # Ramaze
