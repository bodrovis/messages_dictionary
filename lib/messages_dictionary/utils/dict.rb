# frozen_string_literal: true

module MessagesDictionary
  module Utils
    class Dict < Hash
      include Hashie::Extensions::MergeInitializer
      include Hashie::Extensions::IndifferentAccess
    end
  end
end
