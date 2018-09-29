require 'i18n'

module SoT
  class I18nProvider
    attr_writer :scope

    def initialize(ymls_load_path: Dir[File.join('app', '**', '*.yml')])
      I18n.load_path = ymls_load_path
      I18n.available_locales = [:en]
      @scope = nil
    end

    def t(key, vars = {})
      scope = vars.delete(:scope) || @scope
      I18n.t([scope, key].join('.'), vars)
    end
  end
end
