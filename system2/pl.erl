%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(pl).
-export([start/1]).

start(App_Id) ->
  receive 
    {bind, Pl_Map} ->
      next(Pl_Map, App_Id)
  end.

next(Pl_Map, App_Id) -> 
  receive
    {task1, start, MaxMessages, Timeout} -> 
      App_Id ! {pl_deliver, MaxMessages, Timeout};
    {pl_send, RPid, Pid} ->
      PL_R = maps:get(RPid, Pl_Map),
      PL_R ! {p2p_send, Pid};
    {p2p_send, Pid} ->
      % Deliver the message to the app. 
      App_Id ! {pl_deliver, Pid}
  end,
  next(Pl_Map, App_Id).

