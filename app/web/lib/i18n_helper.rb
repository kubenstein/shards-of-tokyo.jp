require 'i18n'

class I18nHelper
  def initialize
    I18n.load_path = Dir[File.join('app', 'web', 'views', '**', '*.yml')]
    I18n.available_locales = [:en]
    @scope = ''
  end

  def scope(scope)
    @scope = scope
  end

  def t(key)
    I18n.t("#{@scope}.#{key}")
  end
end
