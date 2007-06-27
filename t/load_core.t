use strict;
use warnings;
use Test::More 'no_plan';

use_ok('Devel::REPL');
use_ok('Devel::REPL::Script');
use_ok('Devel::REPL::Plugin::History');
use_ok('Devel::REPL::Plugin::LexEnv');
use_ok('Devel::REPL::Plugin::DDS');
use_ok('Devel::REPL::Plugin::Commands');
