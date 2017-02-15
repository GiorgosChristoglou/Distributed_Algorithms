%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(system6).
-export([start/0]).

start() ->
  N = 5,
  Plist = [spawn(process, start, [C]) || C <- lists:seq(1,N)],
  %%% Send message to all the processes. 
  [ P ! {bind, self(), Plist} || P <- Plist],
  bind_pls(N, 0, maps:new(), []),
  termination(N).

  bind_pls(N, Count, Pl_Map, Pl_List) -> 
    receive 
      {pl_id, Pl_Id, Pid} when Count < N - 1 ->
        NPL_Map = maps:put(Pid, Pl_Id, Pl_Map), 
        bind_pls(N, Count + 1, NPL_Map, [Pl_Id | Pl_List]);
      
      {pl_id, Pl_Id, Pid} when Count == N - 1 -> 
        List = [Pl_Id | Pl_List],
        NPL_Map = maps:put(Pid, Pl_Id, Pl_Map),   
        [ Pl ! {bind, NPL_Map} || Pl <- List ],
        [ Pl ! {task1, start, 0, 100000} || Pl <- List]  
    end. 

  termination(N) -> 
    receive 
      {terminate} when N > 1 ->
        termination(N - 1);
      {terminate} when N == 1 -> 
        erlang:halt()
    end.
