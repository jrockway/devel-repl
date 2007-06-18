use strict;
use warnings;
use inc::Module::Install 0.67;

name 'Devel-REPL';
all_from 'lib/Devel/REPL.pm';

install_script 'script/re.pl';

build_requires 'Test::More';
requires 'Moose';
requires 'MooseX::Object::Pluggable';
requires 'MooseX::Getopt';
requires 'namespace::clean';
requires 'File::HomeDir';
requires 'File::Spec';
requires 'Term::ReadLine';
requires 'Lexical::Persistence';
requires 'Data::Dump::Streamer';

auto_install;
WriteAll;
