-module(mp3).
-export([get_id3/1, get_tags/2]).
 
get_id3(File) ->
    case file:open(File, [read, binary]) of
        {ok, MP3} ->
            Result = case file:pread(MP3, {eof, -128}, 128) of
                {eof} -> eof;
                {error, Reason} -> Reason;
                {ok, <<"TAG", Tags/binary>>} ->
                  parse_id3(Tags);
                {ok, _} -> no_id3
            end,
            file:close(MP3),
            Result;
        {error, Reason} -> Reason
    end.
 
get_tags(Tags, L) ->
    lists:map(fun(Tag) -> proplists:get_value(Tag, L) end, Tags).
 
parse_id3(<<T:30/binary,Ar:30/binary,Al:30/binary,Y:4/binary,C:30/binary,G:1/binary>>) ->
    Clean = lists:map(fun cleanup/1, [T, Ar, Al, Y, C, G]),
    {id3v1, lists:zip([title, artist, album, year, comment, genre], Clean)}.
 
cleanup(T) ->
    lists:filter(fun(X) -> X =/= 0 end, binary_to_list(T)).