# frozen_string_literal: true

class Skip < Keycard::Authentication::Method
  def apply
    skipped("skip!")
  end
end

class Success < Keycard::Authentication::Method
  def apply
    succeeded(OpenStruct.new, "success!")
  end
end

class Failure < Keycard::Authentication::Method
  def apply
    failed("failure!")
  end
end
