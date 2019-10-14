module Pod

  @@static_frameworks = []

  def self.store_static_framework_names(names)
    @@static_frameworks = names
  end

  def self.static_framework_names
    @@static_frameworks
  end

  class Specification
    def self.from_string(spec_contents, path, subspec_name = nil)
      name = ''
      path = Pathname.new(path).expand_path
      spec = nil
      case path.extname
      when '.podspec'
        name = File.basename(path, '.podspec')
        Dir.chdir(path.parent.directory? ? path.parent : Dir.pwd) do
          spec = ::Pod._eval_podspec(spec_contents, path)
          unless spec.is_a?(Specification)
            raise Informative, "Invalid podspec file at path `#{path}`."
          end
        end
      when '.json'
        name = File.basename(path, '.podspec.json')
        spec = Specification.from_json(spec_contents)
      else
        raise Informative, "Unsupported specification format `#{path.extname}` for spec at `#{path}`."
      end
      if Pod.static_framework_names.include?(name)
        spec.static_framework = true
      end
      spec.defined_in_file = path
      spec.subspec_by_name(subspec_name, true)
    end
  end

end

Pod::HooksManager.register('cocoapods-force-static-framework', :pre_install) do |context, options|
  Pod.store_static_framework_names(options[:static_frameworks])
end