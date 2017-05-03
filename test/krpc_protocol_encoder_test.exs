defmodule KRPCProtocol.Encoder.Test do
  use ExUnit.Case, async: true

  def node_id,   do: String.duplicate("a", 20)
  def info_hash, do: String.duplicate("b", 20)

  def get_peers_str, do: "d1:ad2:id20:" <> node_id() <> "9:info_hash20:" <> info_hash()

  ###################
  # Other Functions #
  ###################

  test "if gen_tid generates a two bytes string" do
    assert byte_size(KRPCProtocol.gen_tid) == 2
  end

  test "if node_to_binary/2 and comp_form/1 work for IPv4 addresses" do
    ipv4   = {127, 200, 64, 23}
    binary = KRPCProtocol.Encoder.node_to_binary(ipv4, 6881)
    assert KRPCProtocol.Decoder.comp_form(binary) == {ipv4, 6881}
  end

  test "if node_to_binary/2 and comp_form/1 work for IPv6 addresses" do
    ipv6   = {8195, 205, 50123, 38656, 27383, 10495, 65201, 61981}
    binary = KRPCProtocol.Encoder.node_to_binary(ipv6, 6881)
   assert KRPCProtocol.Decoder.comp_form(binary) == {ipv6, 6881}
  end

  ###########
  # Queries #
  ###########


  test "if KRPCProtocol DHT query ping works" do
    str = KRPCProtocol.encode(:ping, tid: "aa", node_id: node_id())
    assert str == "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaae1:q4:ping1:t2:aa1:y1:qe"
  end


  test "if KRPCProtocol DHT query find_node works" do
    str = KRPCProtocol.encode(:find_node, tid: "aa", node_id: node_id(), target: info_hash())
    start = "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa6:target20:bbbbbbbbbbbbbbbbbbbb"
    assert str == start <> "4:want2:n4e1:q9:find_node1:t2:aa1:y1:qe"
  end


  test "if KRPCProtocol DHT query get_peers works" do
    str = KRPCProtocol.encode(:get_peers, node_id: node_id(), info_hash: info_hash(),
      tid: "aa")
    result = get_peers_str() <> "e1:q9:get_peers1:t2:aa1:y1:qe"
    assert str == result
  end


  test "if KRPCProtocol DHT query get_peers works with scrape option" do
    ## With scrape option
    str = KRPCProtocol.encode(:get_peers, node_id: node_id(), info_hash: info_hash(),
      scrape: true, tid: "aa")
    result = get_peers_str() <> "6:scrapei1ee1:q9:get_peers1:t2:aa1:y1:qe"
    assert str == result
  end


  test "if KRPCProtocol DHT query get_peers works with want option" do
    str = KRPCProtocol.encode(:get_peers, node_id: node_id(), info_hash: info_hash(),
      want: "n4", tid: "aa")
    result = get_peers_str() <> "4:want2:n4e1:q9:get_peers1:t2:aa1:y1:qe"
    assert str == result
  end


  test "if KRPCProtocol DHT query get_peers works with want and scrape option" do
    str = KRPCProtocol.encode(:get_peers, node_id: node_id(), info_hash: info_hash(),
      want: "n6", scrape: true, tid: "aa")
    result = get_peers_str() <> "6:scrapei1e4:want2:n6e1:q9:get_peers1:t2:aa1:y1:qe"
    assert str == result
  end


  test "if announce_peer query with options" do
    str = KRPCProtocol.encode(:announce_peer, node_id: node_id(), info_hash: info_hash(),
      token: "aoeusnth", tid: "aa", port: 2342)
    result = "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa9:info_hash20:" <>
      "bbbbbbbbbbbbbbbbbbbb4:porti2342e5:token8:aoeusnthe1:q13:announce_peer1:" <>
      "t2:aa1:y1:qe"
    assert str == result
  end


  test "if announce_peer query with options with implied_port" do
    str = KRPCProtocol.encode(:announce_peer, node_id: node_id(), info_hash: info_hash(),
      token: "aoeusnth", tid: "aa", implied_port: true, port: 2342)
    result = "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa12:implied_porti1e9:info_hash20:" <>
      "bbbbbbbbbbbbbbbbbbbb4:porti2342e5:token8:aoeusnthe1:q13:announce_peer1:" <>
      "t2:aa1:y1:qe"
    assert str == result
  end


end
