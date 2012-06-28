module SunspotResque
  class SessionProxy < ::Sunspot::SessionProxy::AbstractSessionProxy
    attr_reader :original_session

    delegate :config, :batch, :new_search, :search,
             :new_more_like_this, :more_like_this,
             :delete_dirty, :delete_dirty?, :dirty?,
             :to => :original_session

    def initialize(original_session = Sunspot.session)
      @original_session = original_session
    end

    [:index!, :index, :remove!, :remove].each do |method|
      module_eval(<<-RUBY)
        def #{method}(*objects, &block)
          if block_given?
            return original_session.#{method}(*objects, block)
          end
          missed_objects = []
          objects.each do |object|
            if object.is_a? ActiveRecord::Base
              Resque.enqueue Jobs::SunspotWorker, :#{method}, class: object.class.name, id: object.id
            else
              missed_objects << object
            end
          end
          unless missed_objects.empty?
            original_session.#{method}(*missed_objects)
          end
        end
      RUBY
    end

    [:remove_by_id, :remove_by_id!].each do |method|
      module_eval(<<-RUBY)
        def #{method}(klass, id)
          Resque.enqueue Jobs::SunspotWorker, :remove, class: klass, id: id
        end
      RUBY
    end

    [:remove_all, :remove_all!].each do |method|
      module_eval(<<-RUBY)
        def #{method}(*classes)
          Resque.enqueue Jobs::SunspotWorker, :remove_all, classes.flatten.map(&:to_s)
        end
      RUBY
    end

    [:commit_if_dirty, :commit_if_delete_dirty, :commit].each do |method|
      module_eval(<<-RUBY)
        def #{method}
          Resque.enqueue Jobs::SunspotWorker, :commit unless ::Rails.env.production?
        end
      RUBY
    end

    def optimize
      Resque.enqueue Jobs::SunspotWorker, :optimize
    end
  end
end