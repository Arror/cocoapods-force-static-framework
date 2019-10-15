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
      path = Pathname.new(path).expand_path
      spec = nil
      case path.extname
      when '.podspec'
        Dir.chdir(path.parent.directory? ? path.parent : Dir.pwd) do
          spec = ::Pod._eval_podspec(spec_contents, path)
          unless spec.is_a?(Specification)
            raise Informative, "Invalid podspec file at path `#{path}`."
          end
        end
      when '.json'
        spec = Specification.from_json(spec_contents)
      else
        raise Informative, "Unsupported specification format `#{path.extname}` for spec at `#{path}`."
      end
      name = ''
      case path.extname
      when '.podspec'
        name = File.basename(path, '.podspec')
      when '.json'
        name = File.basename(path, '.podspec.json')
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
  reval = options[:static_frameworks]
  if reval and reval.instance_of? Array
    Pod.store_static_framework_names(reval)
  else
    raise Pod::Informative, "请正确设置:static_frameworks, 示例: plugin 'cocoapods-force-static-framework', :static_frameworks => ['RxSwift']"
  end
  
end