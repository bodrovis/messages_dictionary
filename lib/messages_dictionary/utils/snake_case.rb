module MessagesDictionary
  class SpecialString
    attr_accessor :string

    def initialize(string)
      @string = string
    end

    def snake_case
      string.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
    end
  end
end