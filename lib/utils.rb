def min_val(v1, v2)
    if v2 == nil
        return v1
    elsif v1 == nil
        return v2
    elsif v1 < v2
        return v1
    else
        return v2
    end
end

def max_val(v1, v2)
    if v2 == nil
        return v1
    elsif v1 == nil
        return v2
    elsif v1 > v2
        return v1
    else
        return v2
    end
end

def is_number?(object)
      true if Float(object) rescue false
end

def to_f_nil(s)
    begin
        return Float(s)
    rescue
        return nil
    end
end
