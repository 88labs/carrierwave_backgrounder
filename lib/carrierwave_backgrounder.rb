require 'fileutils'
require 'active_support/core_ext/object'
require 'backgrounder/support/backends'
require 'backgrounder/orm/base'
require 'backgrounder/delay'

module CarrierWave
  module Backgrounder
    include Support::Backends

    class << self
      attr_reader :worker_klass
    end

    def self.configure
      yield self

      case backend
      when :active_job
        @worker_klass = "CarrierWave::Workers::ActiveJob"
      when :sidekiq
        @worker_klass = "CarrierWave::Workers"

        require 'sidekiq'
        ::CarrierWave::Workers::ProcessAsset.class_eval do
          include ::Sidekiq::Worker
        end
        ::CarrierWave::Workers::StoreAsset.class_eval do
          include ::Sidekiq::Worker
        end
      end
    end
  end
end

require 'backgrounder/railtie' if defined?(Rails)
