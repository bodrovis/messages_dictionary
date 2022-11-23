# frozen_string_literal: true

module MessagesDictionary
  module Utils
    # This is a "superpowered" Hash allowing indifferent access
    class Dict < Hash
      include Hashie::Extensions::MergeInitializer
      include Hashie::Extensions::IndifferentAccess
    end
  end
end
