require 'uri'

class Params
  def initialize(req, route_params)
    @params = {}
    @params[:id] = route_params[1]
    unless req.query_string.nil?
      parse_www_encoded_form(req.query_string)
    end
    unless req.body.nil?
      parse_www_encoded_form(req.body)
      @params.keys.each do |key|
        p parse_key(key)
      end
    end
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_json
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    decoded_array = URI.decode_www_form(www_encoded_form)

    merge_nested_hash(decoded_array, @params)
    # decoded_array.each do |key, val|
#       @params[key] = val
#     end
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end

  def merge_nested_hash(from_array, to_hash)
    from_array.each do |key, val|
      key_array = parse_key(key)
      add_nested_hash_leg(to_hash, key_array, val)
    end
  end

  def add_nested_hash_leg(to_hash, key_array, value)
    return to_hash[key_array.first] = value if key_array.size == 1

    unless to_hash.key?(key_array.first)
      to_hash[key_array.first] = {}
    end

    add_nested_hash_leg(to_hash[key_array.first], key_array[1..-1], value)
  end
end
