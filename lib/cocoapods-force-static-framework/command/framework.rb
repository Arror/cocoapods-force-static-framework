module Pod

  class Static
    def self.keyword
      :static
    end
  end

  class Podfile

    class TargetDefinition

      def parse_force_static_framework(name, requirements)
        options = requirements.last
        if options.is_a?(Hash) && options[Pod::Static.keyword] != nil
          should_static = options.delete(Pod::Static.keyword)
          requirements.pop if options.empty?
          pod_name = Specification.root_name(name)
          @force_stati_framework_names ||= []
          @force_stati_framework_names.push pod_name
        end
      end

      def force_stati_framework_names
        names = @force_stati_framework_names || []
        if parent != nil and parent.kind_of? TargetDefinition
          names += parent.force_stati_framework_names
        end
        names
      end

      old_method = instance_method(:parse_inhibit_warnings)

      define_method(:parse_inhibit_warnings) do |name, requirements|
        parse_force_static_framework(name, requirements)
        old_method.bind(self).(name, requirements)
      end

    end
  end

  class PodTarget

    old_method = instance_method(:initialize)

    define_method(:initialize) do |sandbox, host_requires_frameworks, user_build_configurations, archs, platform, specs, target_definitions, file_accessors, scope_suffix, build_type|
      bt = Target::BuildType.infer_from_spec(specs.first, :host_requires_frameworks => host_requires_frameworks)
      if target_definitions.first.force_stati_framework_names.include?(specs.first.name)
        bt = Target::BuildType.static_framework
      end
      old_method.bind(self).(sandbox, host_requires_frameworks, user_build_configurations, archs, platform, specs, target_definitions, file_accessors, scope_suffix, :build_type => bt)
    end
    
  end

end