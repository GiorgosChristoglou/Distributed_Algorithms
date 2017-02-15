%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(lossyp2plinks).
-export([start/1]).

start(Beb) ->
  receive 
    {bind, Pl_Map} ->
      next(Pl_Map, Beb, 100) % change reliability. 
  end.

next(Pl_Map, Beb, Reliability) -> 
  R = random:uniform(100),
  receive
    {task1, start, MaxMessages, Timeout} ->
      Beb ! {task1, start, MaxMessages, Timeout};
    {pl_send, RPid, Pid} ->
      PL_R = maps:get(RPid, Pl_Map),
      PL_R ! {p2p_send, Pid};
    {p2p_send, Pid} when R =< Reliability -> 
      % Deliver the message to the app.
      Beb ! {pl_deliver, Pid}
  end,
  next(Pl_Map, Beb, Reliability).

