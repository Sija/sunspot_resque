module SunspotResque
  module Jobs
    class SunspotWorker
      # extend Resque::Plugins::ExponentialBackoff
      # extend Resque::Plugins::LonelyJob
      # extend Resque::Plugins::Pause
      # extend Resque::Plugins::HotHeelsWatcher

      @queue = :solr_indexer

      def self.before_enqueue(sunspot_method = nil, *args)
        raise ArgumentError, 'No sunspot method given' unless sunspot_method
      end

      def self.perform(sunspot_method, object = nil)
        sunspot_method = sunspot_method.to_sym
        if object.is_a? Hash
          object = object.with_indifferent_access
        end
        old_session = Sunspot.session
        begin
          Sunspot.session = Sunspot::Rails.build_session
          case sunspot_method
          when :index, :index!
            self.index object[:class].constantize.find(object[:id])
          when :remove, :remove!
            self.remove_by_id object[:class], object[:id]
          when :remove_all
            self.remove_all object
          when :commit, :optimize
            self.send sunspot_method
          else
            raise "Error: undefined protocol for SunspotWorker: #{sunspot_method} (#{object or 'n/a'})"
          end
        ensure
          Sunspot.session = old_session
        end
      end

      def self.index(object)
        Sunspot.index object
      end

      def self.remove_by_id(klass, id)
        Sunspot.remove_by_id klass, id
      end

      def self.remove_all(classes)
        classes.map! { |klass| klass.constantize }
        Sunspot.remove_all classes
      end

      def self.commit
        # on production, use autocommit in solrconfig.xml 
        # or commitWithin whenever sunspot supports it
        Sunspot.commit unless ::Rails.env.production?
      end

      def self.optimize
        Sunspot.optimize
      end
    end
  end
end