%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(app).
-export([start/2]).

start(P_alias, System) ->
  receive 
    {bind, Rb, Plist, Pid} -> 
      wait_start_message(Plist, P_alias, Rb, Pid, System)
  end.

wait_start_message(Plist, P_alias, Rb, Pid, S) ->
  receive
    {rb_deliver, MaxMessages, Timeout} ->
    if P_alias == 3 -> 
      erlang:send_after(5, self(), timeout);
    true -> 
      erlang:send_after(Timeout, self(), timeout)
    end,
      Messages = init(Plist, maps:new()),
      broadcast_receiver(Plist, P_alias, MaxMessages, Messages, Rb, Pid, S, 0)  
  end.

init([], Messages) -> 
  Messages;
init([Pid | Plist], Messages) ->
  NMessages = maps:put(Pid, {0,0}, Messages),
  init(Plist, NMessages).  

broadcast_receiver(Plist, P_alias, MaxMessages, Messages, Rb, Pid, S, Seq) ->
  receive 
    {rb_deliver, RPid, M_Id} ->
      {B, R} = maps:get(RPid, Messages),
      NMessages = maps:update(RPid, {B, R+1}, Messages),
      broadcast_receiver(Plist, P_alias, MaxMessages, NMessages, Rb, Pid, S, Seq);

    timeout ->
      if P_alias /= 3 -> % This process is meant to be faulty.
        print_map(P_alias, Messages);
        true -> ignore
      end,
      S ! {terminate},
      erlang:exit(normal)
  after 0 -> 
    broadcast_message(Plist, P_alias, Messages, MaxMessages, Rb, Pid, S, Seq)
  end.

broadcast_message(Plist, P_alias, Messages, MaxMessages, Rb, Pid, S, Seq) -> 
  if MaxMessages == -1 -> 
    broadcast_receiver(Plist, P_alias, MaxMessages, Messages, Rb, Pid, S, Seq);

    MaxMessages == 0 ->
    NMessages = send_messages(Plist, Messages, Rb, Pid, Seq),
    broadcast_receiver(Plist, P_alias, MaxMessages, NMessages, Rb, Pid, S, Seq + 1);

    MaxMessages > 1 ->
    NMessages = send_messages(Plist, Messages, Rb, Pid, Seq),
    broadcast_receiver(Plist, P_alias, MaxMessages - 1, NMessages, Rb, Pid, S, Seq+1);
    
    MaxMessages == 1 ->
    NMessages = send_messages(Plist, Messages, Rb, Pid, Seq),
    broadcast_receiver(Plist, P_alias, -1, NMessages, Rb, Pid, S, Seq + 1)
  end. 

send_messages([], Messages, Rb, Self, Seq) ->
  Rb ! {rb_broadcast, Self, {Self, Seq} }, 
  Messages;
send_messages([Pid | Plist], Messages, Rb, Self, Seq) ->
  {B, R} = maps:get(Pid, Messages),
  NMessages = maps:update(Pid, {B + 1, R}, Messages),
  send_messages(Plist, NMessages, Rb, Self, Seq).

print_map(P_alias, Messages) ->
  String = [ lists:flatten(io_lib:format("~p",[Value])) || Value <- maps:values(Messages)],
io:format("~p: ~s~n", [P_alias, string:join(String, " ")]).
