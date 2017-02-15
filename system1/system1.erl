%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(system1).
-export([start/0]).

start() ->
  N = 5,
  Plist = [spawn(process, start, [C]) || C <- lists:seq(1,N)],
  bind_processes(Plist),
  %%% Send message to all the processes. 
  [ P ! {task1, start, 0, 3000} || P <- Plist],
  termination(N).

bind_processes(Plist) -> bind_processes(Plist, Plist).

bind_processes([], Plist) -> done;
bind_processes([Process | Rest], Plist) -> 
  Process ! {bind, Plist, self()},
  bind_processes(Rest, Plist).

termination(N) ->
  receive 
    {terminate} when N > 1 -> 
      termination(N - 1);
    {terminate} when N == 1 ->
      erlang:halt()
  end.
