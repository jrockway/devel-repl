package Devel::REPL::Plugin;

use strict;
use warnings;
use Devel::REPL::Meta::Plugin;
use Moose::Role ();

sub import {
  my $target = caller;
  my $meta = Devel::REPL::Meta::Plugin->initialize($target);
  $meta->Moose::Meta::Class::add_method('meta' => sub { $meta });
  goto &Moose::Role::import;
}

1;
