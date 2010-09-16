-module(itunes_kiss).

-export([
  remove_duplicates/1,
  file_manager/2,
  delete_counter/1,
  insert_new/3
]).


remove_duplicates(Path)->
  Tab = ets:new(music,[set,public]),
  Report = spawn(?MODULE,delete_counter,[0]),
  %% read all files inside the directories using paralle process
  file_crawler:get_files(Path,spawn(?MODULE,file_manager,[Tab,Report])).

delete_counter(N)->
  receive
    sum->
      delete_counter(N+1);
    total->
      io:format("Duplicated files removed with sucess : ~p~n",[N])
  end.
   

file_manager(Tab,Report)->
  receive
    File->
      case mp3:get_id3(File) of
        no_id3->
          void;
        {id3v1,[{title,Title},
                {artist,Artist},
                {album,Album},
                _,_,_]}->
                  spawn(?MODULE,insert_new,[Tab,Report,{{Title,Artist,Album},File}])
      end,
      file_manager(Tab,Report)
  after 1000->
    ets:delete(Tab),
    Report ! total
  end.
  
insert_new(Tab,Report,{Id,File})->
  case ets:insert_new(Tab,{Id}) of
    true->
      void;
    false->
      file:delete(File),
      Report ! sum
  end.