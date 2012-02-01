require 'simple_git'

class Heidi
  # wrap the simple git stuff to get heidi keys
  class Git
    def initialize(root)
      @proxy = SimpleGit.new(root)
    end

    def method_missing(method, *args, &block)
      super
    rescue NoMethodError => e
      @proxy.send(method, *args, &block)
    end

    def [](key)
      @proxy["heidi.#{key}"]
    end

    def []=(key,value)
      @proxy["heidi.#{key}"] = value
    end
  end
end
