# KRPCProtocol
[![Build Status](https://travis-ci.org/cit/krpc_protocol.svg?branch=master)](https://travis-ci.org/cit/krpc_protocol)

KRPCProtocol is an elixir package for decoding and encoding mainline DHT messages.

## Installation

First, add `krpc_protocol` to your `mix.exs` dependencies:

```elixir
def deps do
    [{:krpc_protocol, "~> 0.0.1"}]
end
```

Then, update your dependencies:

```sh-session
$ mix deps.get
```

## Usage

### Encoding

```elixir
iex> KRPCProtocol.encode(:ping, tid: "aa", node_id: "aa")
"d1:ad2:id2:aae1:q4:ping1:t2:aa1:y1:qe"
```

### Decoding

```elixir
iex> KRPCProtocol.decode("d1:ad2:id20:aaaaaaaaaaaaaaaaaaaae1:q4:ping1:t2:aa1:y1:qe")
{:ping, %{node_id: "aaaaaaaaaaaaaaaaaaaa", tid: "aa"}}
```

#### Errors

The decode function returns `{:invalid, error_msg}` if an error occurs during the decoding process such as an unknown message type or invalid bencoded payload.

```elixir
iex> KRPCProtocol.decode("abc")
{:invalid, "Invalid becoded payload: \"abc\""}
```
