defmodule KRPCProtocol.Encoder do

  defp gen_dht_query(command, tid, options) when is_map(options) do
    Bencodex.encode %{"y" => "q", "t" => tid, "q" => command, "a" => options}
  end

  defp gen_dht_response(options, tid) when is_map(options) do
    Bencodex.encode %{"y" => "r", "t" => tid, "r" => options}
  end

  #########
  # Error #
  #########

  def encode(:error, code: code, msg: msg, tid: tid) do
    Bencodex.encode %{"y" => "e", "t" => tid, "e" => [code, msg]}
  end

  ###########
  # Queries #
  ###########

  @doc ~S"""
  This function returns a bencoded Mainline DHT ping query. It needs a 20 bytes
  node id an argument. The tid (transaction id) is optional.

  ## Example
  iex> KRPCProtocol.encode(:ping, tid: "aa", node_id: node_id)
  """
  def encode(:ping, tid: tid, node_id: node_id) do
    gen_dht_query "ping", tid, %{"id" => node_id}
  end
  def encode(:ping, node_id: node_id) do
    encode(:ping, tid: gen_tid(), node_id: node_id)
  end


  @doc ~S"""
  This function returns a bencoded Mainline DHT find_node query. It
  needs a 20 bytes node id and a 20 bytes target id as an argument.

  ## Example
  iex> KRPCProtocol.encode(:find_node, node_id: node_id, target: info_hash)
  """
  def encode(:find_node, tid: tid, node_id: id, target: target) do
    gen_dht_query "find_node", tid, %{"id" => id, "target" => target}
  end
  def encode(:find_node, node_id: id, target: target) do
    encode(:find_node, tid: gen_tid(), node_id: id, target: target)
  end

  def encode(:get_peers, args) do
    options = args[:node_id]
    |> query_dict(args[:info_hash])
    |> add_option_if_defined(:scrape, args[:scrape])
    |> add_option_if_defined(:noseed, args[:noseed])
    |> add_option_if_defined(:want,   args[:want])

    if args[:tid] do
      gen_dht_query("get_peers", args[:tid], options)
    else
      gen_dht_query("get_peers", gen_tid(), options)
    end
  end

  @doc ~S"""
  This function returns a bencoded Mainline DHT announce_peer query.

  ## Example
  iex> KRPCProtocol.encode(:announce_peer, node_id: node_id, info_hash: info_hash)
  """
  def encode(:announce_peer, args) do
    options = args[:node_id]
    |> query_dict(args[:info_hash])
    |> add_option_if_defined(:implied_port, args[:implied_port])
    |> add_option_if_defined(:port, args[:port])
    |> add_option_if_defined(:token, args[:token])

    if args[:tid] do
      gen_dht_query("announce_peer", args[:tid], options)
    else
      gen_dht_query("announce_peer", gen_tid(), options)
    end
  end

  ###########
  # Replies #
  ###########

  def encode(:ping_reply, tid: tid, node_id: node_id) do
    gen_dht_response %{"id" => node_id}, tid
  end

  def encode(:find_node_reply, node_id: id, nodes: nodes, tid: tid) do
    gen_dht_response %{"id" => id, "nodes" => compact_format(nodes)}, tid
  end

  def encode(:get_peers_reply, node_id: id, nodes: nodes, tid: tid, token: token) do
    gen_dht_response %{
      "id"    => id,
      "token" => token,
      "nodes" => compact_format(nodes)
    }, tid
  end

  def encode(:get_peers_reply, node_id: id, values: values, tid: tid, token: token) do
    gen_dht_response %{
      "id"     => id,
      "token"  => token,
      "values" => compact_format_values(values)
    }, tid
  end

  # This function returns a bencoded Mainline DHT get_peers query. It
  # needs a 20 bytes node id and a 20 bytes info_hash as an
  # argument. Optional arguments are [want: "n6", scrape: true]
  defp add_option_if_defined(dict, _key, nil), do: dict
  defp add_option_if_defined(dict, key, value) do
    if value == true do
      Map.put_new(dict, to_string(key), 1)
    else
      Map.put_new(dict, to_string(key), value)
    end
  end

  def compact_format_values(nodes), do: compact_format_values(nodes, "")
  def compact_format_values([], result), do: result
  def compact_format_values([head | tail], result) do
    {ip, port} = head

    result = result <> node_to_binary(ip, port)
    compact_format_values(tail, result)
  end

  def compact_format(nodes), do: compact_format(nodes, "")
  def compact_format([], result), do: result
  def compact_format([head | tail], result) do
    {node_id, ip, port} = head

    result = result <> node_to_binary(node_id, ip, port)
    compact_format(tail, result)
  end

  def node_to_binary({oct1, oct2, oct3, oct4}, port) do
    <<oct1    :: size(8),
      oct2    :: size(8),
      oct3    :: size(8),
      oct4    :: size(8),
      port    :: size(16)>>
  end

  def node_to_binary(node_id, {oct1, oct2, oct3, oct4}, port) do
    <<node_id :: binary,
      oct1    :: size(8),
      oct2    :: size(8),
      oct3    :: size(8),
      oct4    :: size(8),
      port    :: size(16)>>
  end


  defp query_dict(id, info_hash) do
    %{"id" => id, "info_hash" => info_hash}
  end

  @doc ~S"""
  This function generates a 16 bit (2 byte) random transaction id as a
  binary.
  """
  def gen_tid do
    :random.seed(:erlang.system_time(:milli_seconds))

    Stream.repeatedly(fn -> :rand.uniform 255 end)
    |> Enum.take(4)
    |> :binary.list_to_bin
  end

end
