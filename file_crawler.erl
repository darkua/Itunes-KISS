-module(file_crawler).

-export([
  get_files/2
]).

get_files(Path,Pid)->
  case file:list_dir(Path) of
    {ok,Files}->
      lists:foreach(fun(F)->
        spawn(?MODULE,get_files,[Path++"/"++F,Pid])
      end,Files);
    {error,enotdir}->
      Pid ! Path
end.