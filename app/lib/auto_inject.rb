class AutoInject
  attr_accessor :resolver
  def initialize(resolver)
    @resolver = resolver
  end

  def [](*dep_specs)
    default_deps = prepare_deps(dep_specs)

    Module.new do
      define_method(:initialize) do |*args|
        options = args.last
        deps_arg = (options.is_a?(Hash) && options[:deps]) || {}
        @_deps = default_deps.merge(deps_arg)
        super(*args)
      end

      default_deps.each do |name, _|
        define_method(name) { @_deps[name].call }
      end
    end
  end

  private

  def prepare_deps(raw_specs)
    raw_specs
      .map { |raw_spec| normalize_dep_spec(raw_spec) }
      .each_with_object({}) { |spec, h|
        h[spec[:alias]] = -> { @resolver.resolve(spec[:name]) }
      }
  end

  def normalize_dep_spec(raw_spec)
    if raw_spec.is_a?(Hash)
      key = raw_spec.keys[0]
      value = raw_spec[key]
      { alias: key, name: value }
    else
      { alias: raw_spec, name: raw_spec }
    end
  end
end
