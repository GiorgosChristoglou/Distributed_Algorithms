%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(process).
-export([start/1]).

start(P_alias) -> 
  receive 
    {bind, System, Plist} ->
      % Create components. 
      App = spawn(app, start, [P_alias, System]),
      Pl = spawn(pl, start, [App]),

      App ! {bind, Pl, Plist, self()},
      System ! {pl_id, Pl, self()}
  end.

