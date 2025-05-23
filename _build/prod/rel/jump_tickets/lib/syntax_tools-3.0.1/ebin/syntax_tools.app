% This is an -*- erlang -*- file.

{application, syntax_tools,
 [{description, "Syntax tools"},
  {vsn, "3.0.1"},
  {modules, [epp_dodger,
	     erl_comment_scan,
	     erl_prettypr,
	     erl_recomment,
	     erl_syntax,
	     erl_syntax_lib,
             merl,
             merl_transform,
	     prettypr]},
  {registered,[]},
  {applications, [stdlib]},
  {env, []},
  {runtime_dependencies,
   ["compiler-7.0","erts-9.0","kernel-5.0","stdlib-4.0"]}]}.
