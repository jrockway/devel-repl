use strict;
use warnings;
use Test::More 'no_plan';

use_ok('Devel::REPL');
use_ok('Devel::REPL::Script');
use_ok('Devel::REPL::Plugin::Colors');
use_ok('Devel::REPL::Plugin::Commands');

eval 'use PPI';
unless ($@) {
   use_ok('Devel::REPL::Plugin::Completion');
}

eval 'use File::Next';
unless ($@) {
   use_ok('Devel::REPL::Plugin::CompletionDriver::INC');
}

eval 'use B::Keywords';
unless ($@) {
   use_ok('Devel::REPL::Plugin::CompletionDriver::Keywords');
}

eval 'use Lexical::Persistence';
unless ($@) {
   use_ok('Devel::REPL::Plugin::CompletionDriver::LexEnv');
}

use_ok('Devel::REPL::Plugin::CompletionDriver::Globals');
use_ok('Devel::REPL::Plugin::CompletionDriver::Methods');

eval 'use Data::Dump::Concise';
unless ($@) {
   use_ok('Devel::REPL::Plugin::DDC');
}

eval 'use Data::Dump::Streamer';
unless ($@) {
   use_ok('Devel::REPL::Plugin::DDS');
}

use_ok('Devel::REPL::Plugin::DumpHistory');
use_ok('Devel::REPL::Plugin::FancyPrompt');
use_ok('Devel::REPL::Plugin::FindVariable');
use_ok('Devel::REPL::Plugin::History');

eval 'use Sys::SigAction';
unless ($@) {
   use_ok('Devel::REPL::Plugin::Interrupt');
}

# use_ok('Devel::REPL::Plugin::Interrupt') unless $^O eq 'MSWin32';
use_ok('Devel::REPL::Plugin::LexEnv');

eval 'use PPI';
unless ($@) {
   use_ok('Devel::REPL::Plugin::MultiLine::PPI');
}

eval 'use App::Nopaste';
unless ($@) {
   use_ok('Devel::REPL::Plugin::Nopaste');
}

use_ok('Devel::REPL::Plugin::OutputCache');
use_ok('Devel::REPL::Plugin::Packages');
use_ok('Devel::REPL::Plugin::Peek');
eval 'use PPI';
unless ($@) {
   use_ok('Devel::REPL::Plugin::PPI');
}

use_ok('Devel::REPL::Plugin::ReadLineHistory');

eval 'use Module::Refresh';
unless ($@) {
   use_ok('Devel::REPL::Plugin::Refresh');
}

use_ok('Devel::REPL::Plugin::ShowClass');
use_ok('Devel::REPL::Plugin::Timing');
use_ok('Devel::REPL::Plugin::Turtles');
