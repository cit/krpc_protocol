defmodule KRPCProtocol.Decoder.Test do
  use ExUnit.Case, async: true
  doctest KRPCProtocol.Decoder

  def node_id,   do: String.duplicate("a", 20)
  def info_hash, do: String.duplicate("b", 20)

  #####################
  # Corrupted packets #
  #####################

  test "Invalid bencoded message" do
    assert {:invalid, _} = KRPCProtocol.decode("abcdefgh")
  end

  test "Valid bencoded message, but not a valid DHT message" do
    assert {:invalid, _} = KRPCProtocol.decode(<<100, 49, 58, 118, 52, 58, 76, 84, 1, 1, 101>>)
  end

  test "Valid packet but the node id is not 160 bit long" do
    to_short = "d1:ad2:id18:aaaaaaaaaaaaaaaaaae1:q4:ping1:t2:aa1:y1:qe"
    to_long  = "d1:ad2:id22:aaaaaaaaaaaaaaaaaaaaaa:q4:ping1:t2:aa1:y1:qe"

    assert {:invalid, _} = KRPCProtocol.decode(to_short)
    assert {:invalid, _} = KRPCProtocol.decode(to_long)
  end

  test "Find Node response with an invalid byte_size of IPv4 nodes" do
    bin = "d1:rd2:id20:0123456789abcdefghij5:nodes27:aaaaaaaaaaaaaaaaaaaaaaaaabee1:t2:aa1:y1:re"
    assert {:invalid, _} = KRPCProtocol.decode(bin)
  end

  test "Find Node response with an invalid byte_size of a IPv6 node" do
    bin = "d1:rd2:id20:0123456789abcdefghij6:nodes639:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabee1:t2:aa1:y1:re"
    assert {:invalid, _} = KRPCProtocol.decode(bin)
  end

  ##################
  # Error Messages #
  ##################

  test "Error Messages" do
    result = {:error_reply, %{code: 202, msg: "Server Error", tid: "aa"}}
    assert KRPCProtocol.decode("d1:eli202e12:Server Errore1:t2:aa1:y1:ee") == result

    result = {:error_reply, %{code: 201, msg: "A Generic Error Ocurred", tid: "aa"}}
    assert KRPCProtocol.decode("d1:eli201e23:A Generic Error Ocurrede1:t2:aa1:y1:ee") == result

    result = {:error_reply, %{code: 203, msg: "a", tid: nil}}
    assert KRPCProtocol.decode("d1:eli203e1:ae1:v2:UT1:y1:ee") == result
  end

  ########
  # Ping #
  ########

  test "Ping" do
    result = {:ping, %{node_id: node_id(), tid: "aa"}}
    assert KRPCProtocol.decode("d1:ad2:id20:aaaaaaaaaaaaaaaaaaaae1:q4:ping1:t2:aa1:y1:qe") == result
  end


  ##############
  # Ping Reply #
  ##############

  test "Ping Reply" do
    result = {:ping_reply, %{node_id: "AAAAAAAAAAAAAAAAAAAA", tid: "aa"}}
    bin = "d1:rd2:id20:AAAAAAAAAAAAAAAAAAAAe1:t2:aa1:y1:re"
    assert KRPCProtocol.decode(bin) == result
  end

  #############
  # Find Node #
  #############

  test "Find Node Queries" do
    ## valid find_node
    result = {:find_node, %{node_id: node_id(), target: "BBB", tid: "aa"}}
    bin = "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa6:target3:BBBe1:q9:find_node1:t2:aa1:y1:qe"
    assert KRPCProtocol.decode(bin) == result

    ## find_node without target
    bin = "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaae1:q9:find_node1:t2:aa1:y1:qe"
    assert {:error, _} = KRPCProtocol.decode(bin)
  end

  test "Find Node Response with a IPv4 node" do
    result = {:find_node_reply, %{node_id: "0123456789abcdefghij",
               nodes: [{"aaaaaaaaaaaaaaaaaaaa", {{97, 97, 97, 97}, 25189}}],
               tid: "aa", values: nil}}
    bin = "d1:rd2:id20:0123456789abcdefghij5:nodes26:aaaaaaaaaaaaaaaaaaaaaaaabee1:t2:aa1:y1:re"
    assert KRPCProtocol.decode(bin) == result
  end

  test "Find Node Response with a IPv6 node" do
    ipv6_addr = {24929, 24929, 24929, 24929, 24929, 24929, 24929, 24929}
    result = {:find_node_reply, %{node_id: "0123456789abcdefghij",
               nodes: [{"aaaaaaaaaaaaaaaaaaaa", {ipv6_addr, 25189}}],
               tid: "aa", values: nil}}
    bin = "d1:rd2:id20:0123456789abcdefghij6:nodes638:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabee1:t2:aa1:y1:re"
    assert KRPCProtocol.decode(bin) == result
  end

  #############
  # Get_peers #
  #############

  test "Get_Peers request" do
    ## valid get_peers
    result = {:get_peers, %{node_id: node_id(), info_hash: "BBB", tid: "aa"}}
    bin = "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa9:info_hash3:BBBe1:q9:get_peers1:t2:aa1:y1:qe"
    assert KRPCProtocol.decode(bin) == result

    ## get_peers without infohash
    bin = "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaae1:q9:get_peers1:t2:aa1:y1:qe"
    assert {:error, _} = KRPCProtocol.decode(bin)
  end

  #################
  # Announce_peer #
  #################

  test "Announce_peer request" do
    bin = "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa9:info_hash4:aaaa4:porti1e5:token1:ae1:q13:announce_peer1:t1:a1:y1:qe"
    result = {:announce_peer, %{info_hash: "aaaa", node_id: node_id(), tid: "a", token: "a", port: 1}}
    assert KRPCProtocol.decode(bin) == result

    ## announce_peer without info_hash
    bin = "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa4:porti1e5:token1:ae1:q13:announce_peer1:t1:a1:y1:qe"
    assert {:error, _} = KRPCProtocol.decode(bin)

    ## announce_peer without port
    bin = "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa9:info_hash4:aaaa5:token1:ae1:q13:announce_peer1:t1:a1:y1:qe"
    assert {:error, _} = KRPCProtocol.decode(bin)

    bin = "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa9:info_hash4:aaaa4:porti1ee1:q13:announce_peer1:t1:a1:y1:qe"
    assert {:error, _} = KRPCProtocol.decode(bin)
  end


end
