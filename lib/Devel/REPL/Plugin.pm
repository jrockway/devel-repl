package Devel::REPL::Plugin;

use strict;
use warnings;
use Devel::REPL::Meta::Plugin;
use Moose::Role ();

sub import {
  my $target = caller;
  Devel::REPL::Meta::Plugin->initialize($target);
  goto &Moose::Role::import;
}

1;
