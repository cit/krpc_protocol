# KRPCProtocol
[![Build Status](https://travis-ci.org/cit/krpc_protocol.svg?branch=master)](https://travis-ci.org/cit/krpc_protocol)

KRPCProtocol is an elixir package for decoding and encoding mainline DHT messages.

## Installation

First, add `krpc_protocol` to your `mix.exs` dependencies:

```elixir
def deps do
    [{:krpc_protocol, "~> 0.0.4"}]
end
```

Then, update your dependencies:

```sh-session
$ mix deps.get
```

## Usage

### Encoding

#### ping message

```elixir
iex> KRPCProtocol.encode(:ping, tid: "aa", node_id: "aa")
"d1:ad2:id2:aae1:q4:ping1:t2:aa1:y1:qe"
```

#### find node query

```elixir
iex> KRPCProtocol.encode(:find_node, tid: "aa", node_id: "bb", target: "cc")
"d1:ad2:id2:bb6:target2:cc4:want2:n4e1:q9:find_node1:t2:aa1:y1:qe"
```

#### get_peers query

```elixir
iex> KRPCProtocol.encode(:get_peers, node_id: "aa", info_hash: "bb", want: "n6", scrape: true, tid: "aa")
"d1:ad2:id2:aa9:info_hash2:bb6:scrapei1e4:want2:n6e1:q9:get_peers1:t2:aa1:y1:qe"
```

#### announce

```elixir
iex(5)> KRPCProtocol.encode(:announce_peer, node_id: "aa", info_hash: "bb", token: "aoeusnth", tid: "cc", port: 2342)
"d1:ad2:id2:aa9:info_hash2:bb4:porti2342e5:token8:aoeusnthe1:q13:announce_peer1:t2:cc1:y1:qe"
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
