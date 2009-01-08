use strict;
use warnings;
use inc::Module::Install 0.76;

name 'Devel-REPL';
all_from 'lib/Devel/REPL.pm';

install_script 'script/re.pl';

requires 'Moose' => '0.64';
requires 'MooseX::Object::Pluggable' => '0.0009';
requires 'MooseX::Getopt' => '0.15';
requires 'MooseX::AttributeHelpers' => '0.14';
requires 'namespace::clean';
requires 'File::HomeDir';
requires 'Lexical::Persistence';
requires 'Data::Dump::Streamer';
requires 'PPI';
requires 'B::Keywords';
requires 'Task::Weaken';
requires 'App::Nopaste';

# core
requires 'File::Spec';
requires 'Term::ReadLine';
requires 'Term::ANSIColor';

test_requires 'Test::More';

auto_install;
WriteAll;
