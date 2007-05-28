use strict;
use warnings;
use inc::Module::Install 0.67;

name 'Devel-REPL';
all_from 'lib/Devel/REPL.pm';

install_script 'script/re.pl';

requires 'Moose';
requires 'MooseX::Object::Pluggable';
requires 'namespace::clean';
requires 'File::HomeDir';
requires 'File::Spec';
requires 'Term::ReadLine';

auto_install;
WriteAll;
