%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(app).
-export([start/2]).

start(P_alias, System) ->
  receive 
    {bind, Pl, Plist, Pid} -> 
      wait_start_message(Plist, P_alias, Pl, Pid, System)
  end.

wait_start_message(Plist, P_alias, Pl, Pid, S) ->
  receive 
    {pl_deliver, MaxMessages, Timeout} ->
      erlang:send_after(Timeout, self(), timeout),
      Messages = init(Plist, maps:new()),
      broadcast_receiver(Plist, P_alias, MaxMessages, Messages, Pl, Pid, S)  
  end.

init([], Messages) -> 
  Messages;
init([Pid | Plist], Messages) ->
  NMessages = maps:put(Pid, {0,0}, Messages),
  init(Plist, NMessages).  

broadcast_receiver(Plist, P_alias, MaxMessages, Messages, Pl, Pid, S) ->
  receive 
    {pl_deliver, RPid} ->
      {B, R} = maps:get(RPid, Messages),
      NMessages = maps:update(RPid, {B, R+1}, Messages),
      broadcast_receiver(Plist, P_alias, MaxMessages, NMessages, Pl, Pid, S);

    timeout -> 
      print_map(P_alias, Messages),
      S ! {terminate}
      % todo sent a message to terminate the program. 
  after 0 -> 
    broadcast_message(Plist, P_alias, Messages, MaxMessages, Pl, Pid, S)
  end.

broadcast_message(Plist, P_alias, Messages, MaxMessages, Pl, Pid, S) -> 
  if MaxMessages == -1 -> 
    broadcast_receiver(Plist, P_alias, MaxMessages, Messages, Pl, Pid, S);

    MaxMessages == 0 ->
    NMessages = send_messages(Plist, Messages, Pl, Pid),
    broadcast_receiver(Plist, P_alias, MaxMessages, NMessages, Pl, Pid, S);

    MaxMessages > 1 ->
    NMessages = send_messages(Plist, Messages, Pl, Pid),
    broadcast_receiver(Plist, P_alias, MaxMessages - 1, NMessages, Pl, Pid, S);
    
    MaxMessages == 1 ->
    NMessages = send_messages(Plist, Messages, Pl, Pid),
    broadcast_receiver(Plist, P_alias, -1, NMessages, Pl, Pid, S)
  end. 

send_messages([], Messages, Pl, Self) ->
  Messages;
send_messages([Pid | Plist], Messages, Pl, Self) ->
  {B, R} = maps:get(Pid, Messages),
  NMessages = maps:update(Pid, {B + 1, R}, Messages),
  Pl ! {pl_send, Pid, Self}, 
  send_messages(Plist, NMessages, Pl, Self).

print_map(P_alias, Messages) ->
  String = [ lists:flatten(io_lib:format("~p",[Value])) || Value <- maps:values(Messages)],
io:format("~p: ~s~n", [P_alias, string:join(String, " ")]).
