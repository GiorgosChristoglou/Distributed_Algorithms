%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(process).
-export([start/1]).

start(P_alias) -> 
  receive 
    {bind, System, Plist} ->
      % Create components. 
      App = spawn(app, start, [P_alias, System]),
      Beb = spawn(beb, start, []),
      Pl = spawn(pl, start, [Beb]),

      Beb ! {bind, Pl, App, Plist},
      App ! {bind, Beb, Plist, self()},
      System ! {pl_id, Pl, self()}
  end.

