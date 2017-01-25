defmodule KRPCProtocol do
  defdelegate encode(message, args), to: KRPCProtocol.Encoder
  defdelegate decode(message),       to: KRPCProtocol.Decoder
  defdelegate gen_tid,               to: KRPCProtocol.Encoder
end
