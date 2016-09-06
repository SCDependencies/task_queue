-module(task_queue_sup).

-behaviour(supervisor).

%% API
-export([
        start_link/0,
        start_link/1,
        child_spec/4,
        supervisor_spec/3
    ]).

%% Supervisor callbacks
-export([init/1]).

%%%===================================================================
%%% API functions
%%%===================================================================

start_link() ->
    supervisor:start_link(?MODULE, []).

start_link(Args) ->
  supervisor:start_link(?MODULE, Args).

child_spec(Id, Mod, Type, Args) ->
    {Id, {Mod, start_link, Args}, permanent, 500, Type, [Mod]}.

supervisor_spec(Module, Args, Options) ->
  Id = {?MODULE, proplists:get_value(task_manager, Options, Module)},
  {Id, {?MODULE, start_link, [[Module, Args, Options]]}, permanent, 500, supervisor, [?MODULE]}.

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

init([]) ->
    {ok, {{one_for_all, 0, 1}, [] }};
init([Module, Args, Options]) ->
  NewOptions =
    case proplists:get_value(task_manager, Options) of
      undefined ->
        [{task_manager, Module}];
      _ ->
        []
    end ++
    [{worker_module, Module},
      {worker_module_args, Args} | Options],
  {ok, {{rest_for_one, 0, 1}, [
    task_queue_sup:child_spec(
      <<"task_queue_manager">>, task_queue_manager, worker, [ NewOptions ]),
    task_queue_sup:child_spec(
      <<"task_queue_workers_sup">>, task_queue_workers_sup, supervisor, [ NewOptions ])
  ] }}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

