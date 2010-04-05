package Devel::REPL::Backend::API;
use Moose::Role;
use namespace::autoclean;

# TODO: trim this down a bit

requires 'formatted_eval';
requires 'format_result';
requires 'format_error';
requires 'format';
requires 'is_error';
requires 'eval';
requires 'compile';
requires 'wrap_as_sub';
requires 'mangle_line';
requires 'execute';
requires 'error_return';

1;
