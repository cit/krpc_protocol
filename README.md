# KRPCProtocol
[![Build Status](https://travis-ci.org/cit/krpc_protocol.svg?branch=master)](https://travis-ci.org/cit/krpc_protocol)

KRPCProtocol is an elixir package for decoding and encoding mainline DHT messages.

## Encoding

```elixir
iex> KRPCProtocol.encode(:ping, tid: "aa", node_id: "aa")
"d1:ad2:id2:aae1:q4:ping1:t2:aa1:y1:qe"
```

## Decoding

```elixir
iex> KRPCProtocol.decode("d1:ad2:id20:aaaaaaaaaaaaaaaaaaaae1:q4:ping1:t2:aa1:y1:qe")
{:ping, %{node_id: "aaaaaaaaaaaaaaaaaaaa", tid: "aa"}}
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add krpc_protocol to your list of dependencies in `mix.exs`:

        def deps do
          [{:krpc_protocol, "~> 0.0.1"}]
        end

  2. Ensure krpc_protocol is started before your application:

        def application do
          [applications: [:krpc_protocol]]
        end
