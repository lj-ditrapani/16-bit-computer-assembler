module Assembler
  # Mapping from symbols to integers
  class SymbolTable < Hash
    def self.add_register_symbols
      add_hex_register_symbols(add_decimal_register_symbols(BASE.dup))
    end

    def self.add_decimal_register_symbols(base)
      (0...16).each do |i|
        base[('R' + i.to_s).to_sym] = i
      end
      base
    end

    def self.add_hex_register_symbols(base)
      ('A'..'F').each_with_index do |c, i|
        base[('R' + c).to_sym] = i + 10
      end
      base
    end

    BASE = {
      :audio => 0xD800,
      :"net-in" => 0xDC00,
      :"net-out" => 0xE000,
      :"storage-in" => 0xE400,
      :"storage-out" => 0xE800,
      :tiles => 0xEC00,
      :grid => 0xF400,
      :"cell-x-y-flip" => 0xFD60,
      :sprites => 0xFE8C,
      :"cell-colors" => 0xFF8C,
      :"sprite-colors" => 0xFFAC,
      :keyboard => 0xFFFA,
      :"net-status" => 0xFFFB,
      :"enable-bits" => 0xFFFC,
      :"storage-read-address" => 0xFFFD,
      :"storage-write-address" => 0xFFFE,
      :"frame-interrupt-vector" => 0xFFFF
    }

    SYMBOL_TABLE = add_register_symbols

    def initialize
      super
      merge! SYMBOL_TABLE
    end

    def []=(key, value)
      super(key.to_sym, value)
    end

    def [](key)
      value = super(key.to_sym)
      message = "Undefined symbol: #{key.inspect}"
      fail(AsmError, message) if value.nil?
      value
    end

    def set_token(name_symbol, value_token)
      self[name_symbol] = get_int value_token
    end

    private

    def get_int(value_token)
      if value_token.type == :symbol
        self[value_token.value]
      else
        value_token.value
      end
    end
  end
end
