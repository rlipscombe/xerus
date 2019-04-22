defmodule Sqdis.Parser do
  # A .cnut file is 0xFAFA followed by a serialized closure.
  def dump_bytecode_stream(<<0xFA, 0xFA, rest::binary()>>) do
    dump_closure(rest)
  end

  # A closure is RIQS, 3 sizeof values, then the function proto for 'main', then LIAT.
  defp dump_closure(
         <<"RIQS", _sizeof_char::little-32, _sizeof_int::little-32, _sizeof_float::little-32,
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
    {_source_name, rest} = read_object(rest)
    {_function_name, rest} = read_object(rest)

    # Table sizes
    <<"TRAP", rest::binary()>> = rest

    <<nliterals::little-64, nparameters::little-64, noutervalues::little-64,
      nlocalvarinfos::little-64, nlineinfos::little-64, ndefaultparams::little-64,
      ninstructions::little-64, nfunctions::little-64, rest::binary()>> = rest

    # Literals
    <<"TRAP", rest::binary()>> = rest
    {_literals, rest} = dump_literals(nliterals, [], rest)

    # Parameters
    <<"TRAP", rest::binary()>> = rest
    {_parameters, rest} = dump_parameters(nparameters, [], rest)

    # Outers
    <<"TRAP", rest::binary()>> = rest
    {_outers, rest} = dump_outers(noutervalues, [], rest)

    # Locals
    <<"TRAP", rest::binary()>> = rest
    {_locals, rest} = dump_locals(nlocalvarinfos, [], rest)

    # Line infos
    <<"TRAP", rest::binary()>> = rest
    {_lineinfos, rest} = dump_lineinfos(nlineinfos, [], rest)

    # Default params
    <<"TRAP", rest::binary()>> = rest
    {_defaultparams, rest} = dump_defaultparams(ndefaultparams, [], rest)

    # Instructions
    <<"TRAP", rest::binary()>> = rest
    {_instructions, rest} = dump_instructions(ninstructions, [], rest)

    # Functions
    <<"TRAP", rest::binary()>> = rest
    {_, rest} = dump_functions(nfunctions, [], rest)

    # Trailer
    <<_stack_size::little-64, _is_generator::little-8, _var_params::little-64, rest::binary()>> =
      rest

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
    acc = acc ++ [{line, op}]
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
    inspect_instruction(instr)
    acc = acc ++ [instr]
    dump_instructions(count - 1, acc, rest)
  end

  defp dump_instruction(
         <<arg1::unsigned-little-32, op::unsigned-little-8, arg0::unsigned-little-8,
           arg2::unsigned-little-8, arg3::unsigned-little-8, rest::binary()>>
       ) do
    instr = {op, arg0, arg1, arg2, arg3}
    {instr, rest}
  end

  @_OP_LOAD 0x01
  @_OP_LOADINT 0x02
  @_OP_CALL 0x06
  @_OP_PREPCALLK 0x08
  @_OP_ADD 0x11
  @_OP_RETURN 0x17

  defp inspect_instruction({@_OP_LOAD, arg0, arg1, _arg2 = 0, _arg3 = 0}) do
    IO.puts("load #{arg1} r#{arg0}  ; r#{arg0} := literal[#{arg1}]")
  end

  defp inspect_instruction({@_OP_LOADINT, arg0, arg1, _arg2 = 0, _arg3 = 0}) do
    IO.puts("loadint #{arg1} r#{arg0}   ; r#{arg0} := #{arg1}")
  end

  defp inspect_instruction({@_OP_CALL, arg0, arg1, arg2, arg3}) do
    # call uses different args depending on *what* you're calling.
    sarg0 = to_signed(arg0)
    IO.puts("call r#{arg1} #{sarg0} #{arg3} &r#{arg2}")
    IO.puts("    ; r2(r#{arg2}..r#{arg2+arg3-1})")
  end

  defp inspect_instruction({@_OP_PREPCALLK, arg0, arg1, arg2, arg3}) do
    # key := literal[arg1]
    # obj := r[arg2]
    # TODO: arg2 is 'selfidx'; don't know what that's used for yet.
    # r[arg3] := obj
    # trg := obj[key]
    IO.puts("prepcallk r#{arg2} #{arg1} r#{arg0} r#{arg3}")
    IO.puts("    ; key := literal[#{arg1}]")
    IO.puts("    ; obj := r#{arg2}")
    IO.puts("    ; r#{arg3} := obj")
    IO.puts("    ; r#{arg0} := obj[key]")
  end

  defp inspect_instruction({@_OP_ADD, arg0, arg1, arg2, _arg3 = 0}) do
    # lhs = r[arg2], rhs = r[arg1], trg = r[arg0]
    IO.puts("add r#{arg2} r#{arg1} r#{arg0}   ; r#{arg0} := r#{arg2} + r#{arg1}")
  end

  defp inspect_instruction({@_OP_RETURN, _arg0 = 255, _arg1 = 0, _arg2 = 0, _arg3 = 0}) do
    # TODO: There's some complicated stuff going on here.
    IO.puts("return")
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

  defp to_signed(u) do
    <<s::signed-little-8>> = <<u::unsigned-little-8>>
    s
  end
end
