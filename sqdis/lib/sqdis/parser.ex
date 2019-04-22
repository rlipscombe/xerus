defmodule Sqdis.Parser do
  # A .cnut file is 0xFAFA followed by a serialized closure.
  def dump_bytecode_stream(<<0xFA, 0xFA, rest::binary()>>) do
    dump_closure(rest)
  end

  # A closure is RIQS, 3 sizeof values, then the function proto for 'main', then LIAT.
  defp dump_closure(
         <<"RIQS", sizeof_char::little-32, sizeof_int::little-32, sizeof_float::little-32,
           rest::binary()>>
       ) do
    rest = dump_function_proto(rest)
    <<"LIAT", rest::binary>> = rest
    <<>> = rest
  end

  # A function proto is multiple parts
  defp dump_function_proto(rest) do
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
    {literals, rest} = dump_literals(nliterals, [], rest)

    # Parameters
    <<"TRAP", rest::binary()>> = rest
    {parameters, rest} = dump_parameters(nparameters, [], rest)

    # Outers
    <<"TRAP", rest::binary()>> = rest
    {outers, rest} = dump_outers(noutervalues, [], rest)

    # Locals
    <<"TRAP", rest::binary()>> = rest
    {locals, rest} = dump_locals(nlocalvarinfos, [], rest)

    # Line infos
    <<"TRAP", rest::binary()>> = rest
    {lineinfos, rest} = dump_lineinfos(nlineinfos, [], rest)

    # Default params
    <<"TRAP", rest::binary()>> = rest
    {defaultparams, rest} = dump_defaultparams(ndefaultparams, [], rest)

    # Instructions
    <<"TRAP", rest::binary()>> = rest
    {instructions, rest} = dump_instructions(ninstructions, [], rest)

    # Functions
    <<"TRAP", rest::binary()>> = rest
    {_, rest} = dump_functions(nfunctions, [], rest)

    # Trailer
    <<stack_size::little-64, is_generator::little-8, var_params::little-64, rest::binary()>> = rest
    rest
  end

  # TODO: Lot of duplication here.
  defp dump_literals(_count = 0, acc, rest) do
    {acc, rest}
  end

  defp dump_literals(count, acc, rest) do
    # TODO: Literals are zero-indexed, so we probably want index, count.
    {literal, rest} = read_object(rest)
    acc = acc ++ [literal]
    dump_literals(count - 1, acc, rest)
  end

  defp dump_parameters(_count = 0, acc, rest) do
    {acc, rest}
  end

  defp dump_parameters(count, acc, rest) do
    {parameter, rest} = read_object(rest)
    acc = acc ++ [parameter]
    dump_parameters(count - 1, acc, rest)
  end

  defp dump_outers(_count = 0, acc, rest) do
    {acc, rest}
  end

  defp dump_locals(_count = 0, acc, rest) do
    {acc, rest}
  end

  defp dump_locals(count, acc, rest) do
    {name, rest} = read_object(rest)
    <<pos::little-64, start_op::little-64, end_op::little-64, rest::binary()>> = rest
    acc = acc ++ [{name, pos, start_op, end_op}]
    dump_locals(count - 1, acc, rest)
  end

  defp dump_lineinfos(_count = 0, acc, rest) do
    {acc, rest}
  end

  defp dump_lineinfos(count, acc, rest) do
    <<line::little-64, op::little-64, rest::binary()>> = rest
    dump_lineinfos(count - 1, acc, rest)
  end

  defp dump_defaultparams(_count = 0, acc, rest) do
    {acc, rest}
  end

  defp dump_instructions(_count = 0, acc, rest) do
    {acc, rest}
  end

  defp dump_instructions(count, acc, rest) do
    {instr, rest} = dump_instruction(rest)
    acc = acc ++ [instr]
    dump_instructions(count - 1, acc, rest)
  end

  defp dump_instruction(
         <<arg1::little-32, op::little-8, arg0::little-8, arg2::little-8, arg3::little-8,
           rest::binary()>>
       ) do
    instr = {op, arg0, arg1, arg2, arg3} |> IO.inspect
    {instr, rest}
  end

  defp dump_functions(_count = 0, acc, rest) do
    {acc, rest}
  end

  @_OT_STRING 0x08000010

  # TODO: Electric Imp uses 32-bit-compiled squirrel, so the length is little-32; how to parameterise that?
  defp read_object(
         <<@_OT_STRING::little-32, length::little-64, value::bytes-size(length), rest::binary()>>
       ) do
    {value, rest}
  end
end
