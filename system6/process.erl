%%% Georgios Christoglou (gc1314) Pavlos Kosmetatos (pk2914).
-module(process).
-export([start/1]).

start(P_alias) -> 
  receive 
    {bind, System, Plist} ->
      % Create components. 
      App = spawn(app, start, [P_alias, System]),
      Beb = spawn(beb, start, []),
      Erb = spawn(rb, start, []),
      Pl = spawn(lossyp2plinks, start, [Beb]),

      Beb ! {bind, Pl, Erb, Plist},
      Erb ! {bind, App, Beb}, 
      App ! {bind, Erb, Plist, self()},
      System ! {pl_id, Pl, self()}
  end.

