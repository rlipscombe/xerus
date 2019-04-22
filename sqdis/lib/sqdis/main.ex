defmodule Sqdis.Cli do
  def main([path]) do
    cnut = File.read!(path)
    Sqdis.Parser.dump_bytecode_stream(cnut)
  end
end
