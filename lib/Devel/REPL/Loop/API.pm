package Devel::REPL::Loop::API;
use Moose::Role;
use namespace::autoclean;

requires 'frontend';
requires 'backend';

requires 'run_once_safely';
requires 'run_once';
requires 'run';

1;
