use strict;
use warnings;
use Test::More 'no_plan';

use_ok('Devel::REPL');
use_ok('Devel::REPL::Script');
use_ok('Devel::REPL::Plugin::Colors');
use_ok('Devel::REPL::Plugin::Commands');
use_ok('Devel::REPL::Plugin::Completion');
use_ok('Devel::REPL::Plugin::CompletionDriver::Globals');
use_ok('Devel::REPL::Plugin::CompletionDriver::INC');
use_ok('Devel::REPL::Plugin::CompletionDriver::Keywords');
use_ok('Devel::REPL::Plugin::CompletionDriver::LexEnv');
use_ok('Devel::REPL::Plugin::CompletionDriver::Methods');
use_ok('Devel::REPL::Plugin::DDC');
use_ok('Devel::REPL::Plugin::DDS');
use_ok('Devel::REPL::Plugin::DumpHistory');
use_ok('Devel::REPL::Plugin::FancyPrompt');
use_ok('Devel::REPL::Plugin::FindVariable');
use_ok('Devel::REPL::Plugin::History');
# Interrupt depends on Sys::SigAction which
# is not available on win32 so we skip the
# test there
use_ok('Devel::REPL::Plugin::Interrupt') unless $^O eq 'MSWin32';
use_ok('Devel::REPL::Plugin::LexEnv');
use_ok('Devel::REPL::Plugin::Nopaste');
use_ok('Devel::REPL::Plugin::OutputCache');
use_ok('Devel::REPL::Plugin::PPI');
use_ok('Devel::REPL::Plugin::Packages');
use_ok('Devel::REPL::Plugin::Peek');
use_ok('Devel::REPL::Plugin::ReadLineHistory');
use_ok('Devel::REPL::Plugin::Refresh');
use_ok('Devel::REPL::Plugin::ShowClass');
use_ok('Devel::REPL::Plugin::Timing');
use_ok('Devel::REPL::Plugin::Turtles');
