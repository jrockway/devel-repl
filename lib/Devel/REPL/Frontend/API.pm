package Devel::REPL::Frontend::API;
use Moose::Role;
use namespace::autoclean;

requires 'read';
requires 'print';

1;
