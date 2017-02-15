%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(process).
-export([start/1]).

start(P_alias) ->
  receive 
    {bind, Plist, System} -> wait_start_message(Plist, P_alias, System)
  end.

wait_start_message(Plist, P_alias, S) ->
  receive 
    {task1, start, MaxMessages, Timeout} ->
      erlang:send_after(Timeout, self(), timeout),
      Messages = init(Plist, maps:new()),
      broadcast_receiver(Plist, P_alias, MaxMessages, Messages, S)  
  end.

init([], Messages) -> 
  Messages;
init([Pid | Plist], Messages) ->
  NMessages = maps:put(Pid, {0,0}, Messages),
  init(Plist, NMessages).  

broadcast_receiver(Plist, P_alias, MaxMessages, Messages, S) ->
  receive 
    {message, Pid} ->
      {B, R} = maps:get(Pid, Messages),
      NMessages = maps:update(Pid, {B, R+1}, Messages),
      broadcast_receiver(Plist, P_alias, MaxMessages, NMessages, S);

    timeout -> 
      print_map(P_alias, Messages),
      S ! {terminate}
      % todo sent a message to terminate the program. 
  after 0 ->
    broadcast_message(Plist, P_alias, Messages, MaxMessages, S)
  end.

broadcast_message(Plist, P_alias, Messages, MaxMessages, S) -> 
  if MaxMessages == -1 -> 
    broadcast_receiver(Plist, P_alias, MaxMessages, Messages, S);

    MaxMessages == 0 ->
    NMessages = send_messages(Plist, Messages),
    broadcast_receiver(Plist, P_alias, MaxMessages, NMessages, S);

    MaxMessages > 1 ->
    NMessages = send_messages(Plist, Messages),
    broadcast_receiver(Plist, P_alias, MaxMessages - 1, NMessages, S);
    
    MaxMessages == 1 ->
    NMessages = send_messages(Plist, Messages),
    broadcast_receiver(Plist, P_alias, -1, NMessages, S)
  end.

send_messages([], Messages) ->
  Messages;
send_messages([Pid | Plist], Messages) ->
  {B, R} = maps:get(Pid, Messages),
  NMessages = maps:update(Pid, {B + 1, R}, Messages),
  Pid ! {message, self()},
  send_messages(Plist, NMessages).

print_map(P_alias, Messages) ->
  String = [ lists:flatten(io_lib:format("~p",[Value])) || Value <- maps:values(Messages)],
  io:format("~p: ~s~n", [P_alias, string:join(String, " ")]).
