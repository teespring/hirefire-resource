# encoding: utf-8

module HireFire
  module Resource
    extend self

    # @return [Array] The configured dynos.
    #
    attr_accessor :dynos

    # Sets the `@dynos` instance variable to an empty Array to hold all the dyno configuration.
    #
    # @example Resource Configuration
    #   HireFire::Resource.configure do |config|
    #     config.dyno(:worker) do
    #       # Macro or Custom logic for the :worker dyno here..
    #     end
    #   end
    #
    # @yield [HireFire::Resource] to allow for block-style configuration.
    #
    def configure
      @dynos ||= []
      retry_set
      scheduled_set
      yield self
    end

    # Will be used through block-style configuration with the `configure` method.
    #
    # @param [Symbol, String] name the name of the dyno as defined in the Procfile.
    # @param [Proc] block an Integer containing the quantity calculation logic.
    #
    def dyno(name, &block)
      @dynos << { :name => name, :quantity => block }
    end

    def scheduled_set
      h = Hash.new { |hash, key| hash[key] = 0 }
      $scheduled_set = Sidekiq::ScheduledSet.new.each_with_object(h) do |job, object|
        object[job['queue']] += 1
      end
    end

    def retry_set
      h = Hash.new { |hash, key| hash[key] = 0 }
      $retry_set = Sidekiq::RetrySet.new.each_with_object(h) do |job, object|
        object[job['queue']] += 1
      end
    end
  end
end

