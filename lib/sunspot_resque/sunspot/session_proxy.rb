module Sunspot::Resque
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
      on_unsaved = if method =~ /index/
        %q(raise ArgumentError, "Cannot index #{object} that has not been saved")
      else
        %q(next)
      end
      module_eval(<<-RUBY)
        def #{method}(*objects, &block)
          return original_session.#{method}(*objects, block) if block_given?
          
          missed_objects = []
          objects.each do |object|
            if object.is_a? ActiveRecord::Base
              unless object.persisted?
                #{on_unsaved}
              end
              Resque.enqueue Worker, :#{method}, class: object.class.name, id: object.id
            else
              missed_objects << object
            end
          end
          original_session.#{method}(*missed_objects) unless missed_objects.empty?
        end
      RUBY
    end

    [:remove_by_id, :remove_by_id!].each do |method|
      module_eval(<<-RUBY)
        def #{method}(klass, id)
          Resque.enqueue Worker, :remove, class: klass, id: id
        end
      RUBY
    end

    [:remove_all, :remove_all!].each do |method|
      module_eval(<<-RUBY)
        def #{method}(*classes)
          Resque.enqueue Worker, :remove_all, classes.flatten.map(&:to_s)
        end
      RUBY
    end

    [:commit_if_dirty, :commit_if_delete_dirty, :commit].each do |method|
      module_eval(<<-RUBY)
        def #{method}
          Resque.enqueue Worker, :commit unless ::Rails.env.production?
        end
      RUBY
    end

    def optimize
      Resque.enqueue Worker, :optimize
    end
  end
end