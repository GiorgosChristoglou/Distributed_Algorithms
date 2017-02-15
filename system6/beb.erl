%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(beb).
-export([start/0]).

start() -> 
  receive 
    {bind, Pl, Rb, Plist} -> next(Plist, Rb, Pl)
  end.

next(Plist, Rb, Pl) -> 
  receive 
    {task1, start, MaxMessages, Timeout} ->
      Rb ! {task1 , start, MaxMessages, Timeout};
    {beb_broadcast, Pid, M_Id} ->
      [Pl ! {pl_send, RPid, Pid, M_Id} || RPid <- Plist];
    {pl_deliver, Pid, M_Id} ->
      Rb ! {beb_deliver, Pid, M_Id}
  end, 
  next(Plist, Rb, Pl).

