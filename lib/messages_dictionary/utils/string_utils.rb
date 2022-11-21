# frozen_string_literal: true

module MessagesDictionary
  module Utils
    # Utility methods for strings
    module StringUtils
      refine String do
        # Underscore a string such that camelcase, dashes and spaces are
        # replaced by underscores.
        def snakecase
          gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
            gsub(/([a-z\d])([A-Z])/, '\1_\2').
            tr('-', '_').
            gsub(/\s/, '_').
            gsub(/__+/, '_').
            downcase
        end
      end
    end
  end
end
