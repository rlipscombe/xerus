defmodule Sqdis.Cli do
  def main([path]) do
    cnut = File.read!(path)
    parse_bytecode_stream(cnut)
  end

  # A .cnut file is 0xFAFA followed by a serialized closure.
  defp parse_bytecode_stream(<<0xFA, 0xFA, rest::binary()>>) do
    parse_closure(rest)
  end

  # A closure is RIQS, 3 sizeof values, then the function proto for 'main', then LIAT.
  defp parse_closure(
         <<"RIQS", sizeof_char::little-32, sizeof_int::little-32, sizeof_float::little-32,
           rest::binary()>>
       ) do
    rest = parse_function_proto(rest)
    <<"LIAT", rest::binary>> = rest
    <<>> = rest
  end

  # A function proto is multiple parts
  defp parse_function_proto(rest) do
    # Names
    <<"TRAP", rest::binary()>> = rest
    {source_name, rest} = read_object(rest)
    {function_name, rest} = read_object(rest)

    # Table sizes
    <<"TRAP", rest::binary()>> = rest
    <<nliterals::little-64, nparameters::little-64, noutervalues::little-64,
      nlocalvarinfos::little-64, nlineinfos::little-64, ndefaultparams::little-64,
      ninstructions::little-64, nfunctions::little-64, rest::binary()>> = rest

    # Literals
    <<"TRAP", rest::binary()>> = rest
    {literals, rest} = parse_literals(nliterals, rest)
    rest
  end

  @_OT_STRING 0x08000010

  # TODO: Electric Imp uses 32-bit-compiled squirrel, so the length is little-32; how to parameterise that?
  defp read_object(<<@_OT_STRING::little-32, length::little-64, value::bytes-size(length), rest::binary()>>) do
    {value, rest}
  end
end
