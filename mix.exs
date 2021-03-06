defmodule KrpcProtocol.Mixfile do
  use Mix.Project

  def project() do
    [app: :krpc_protocol,
     version: "0.0.5",
     elixir: "~> 1.2",
     build_embedded:  Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application() do
    []
  end

  defp deps() do
    [{:bencodex, "~> 1.0.0"},
     {:ex_doc,   "~> 0.19", only: :dev}]
  end

  defp description() do
    """
    KRPCProtocol is an elixir package for decoding and encoding mainline DHT messages.
    """
  end

  defp package() do
    [name:        :krpc_protocol,
     files:       ["lib", "config", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Florian Adamsky"],
     licenses:    ["MIT"],
     links:       %{"GitHub" => "https://github.com/cit/krpc_protocol"}]
  end

end
