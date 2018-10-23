throw('unnecessary Hash#slice polyfill') if Hash.respond_to?(:slice)

class Hash
  def slice(*keys)
    ::Hash[[keys, values_at(*keys)].transpose]
  end
end
