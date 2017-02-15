%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(beb).
-export([start/0]).

start() -> 
  receive 
    {bind, Pl, App, Plist} -> next(Plist, App, Pl)
  end.

next(Plist, App, Pl) -> 
  receive 
    {task1, start, MaxMessages, Timeout} ->
      App ! {beb_deliver, MaxMessages, Timeout};
    {beb_broadcast, Pid} ->
      [Pl ! {pl_send, RPid, Pid} || RPid <- Plist];
    {pl_deliver, Pid} ->
      App ! {beb_deliver, Pid}
  end,
  next(Plist, App, Pl).
