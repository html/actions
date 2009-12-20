module Actions
  class ActionNotIncluded < StandardError
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  class Storage
    @@actions = {}
    class << self
      def set_action(name, &block)
        @@actions[name.to_sym] = block
      end
      
      def action(name)
        @@actions[name]
      end

      def action_exists?(name)
        !@@actions[name].nil?
      end
    end
  end

  module ClassMethods
    def action(*args)
      options = args.extract_options!

      if !options.empty?
        options.each do |key,val|
          generate_action(key, val)
        end
      end

      if !args.empty?
        args.each do |val|
          generate_action(val, val)
        end
      end
    end

    protected
      def generate_action(source, target)
        if !Actions::Storage.action_exists?(source)
          raise ActionNotIncluded, "Action #{source} does not exists in Actions::Repository, please define it"
        end

        define_method target, Actions::Storage.action(source)
      end
  end

  module Repository
    def self.define_action(name, &block)
      Actions::Storage.set_action(name, &Proc.new(&block))
    end
  end
end
