-module(task_queue_fake_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  {ok, {{one_for_one, 5, 10},
    [
%%      task_queue_sup:supervisor_spec(test_worker, [], [{task_manager, q11}]),
%%      task_queue_sup:supervisor_spec(test_worker, [], [{task_manager, q12}])
    ]}}.

