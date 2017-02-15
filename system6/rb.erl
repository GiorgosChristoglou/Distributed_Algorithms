%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(rb).
-export([start/0]).

start() ->
  receive
    {bind, App, Beb} -> 
      next(App, Beb, [])
  end.

next(App, Beb, Delivered) ->
  receive 
    {task1, start, MaxMessages, Timeout} ->
      App ! {rb_deliver, MaxMessages, Timeout},
      next(App, Beb, Delivered);
    {rb_broadcast, Pid, M_Id} ->
      Beb ! {beb_broadcast, Pid, M_Id},
      next(App, Beb, Delivered);
    {beb_deliver, Pid, {P, M}} ->
      IsMember = lists:member({P, M}, Delivered),
      if IsMember -> 
        next(App, Beb, Delivered);
      true -> 
        App ! {rb_deliver, Pid, {P, M}},
        Beb ! {beb_broadcast, Pid, {P, M}},
        next(App, Beb, Delivered ++ [{P , M}])
     end
  end. 
        
