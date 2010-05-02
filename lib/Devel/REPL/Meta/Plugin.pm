package Devel::REPL::Meta::Plugin;

use Moose;

extends 'Moose::Meta::Role';

before 'apply' => sub {
  my ($self, $other) = @_;
  return unless $other->isa('Devel::REPL');
  if (my $pre = $self->get_method('BEFORE_PLUGIN')) {
    $pre->body->($other, $self);
  }
};

after 'apply' => sub {
  my ($self, $other) = @_;
  return unless $other->isa('Devel::REPL');
  if (my $pre = $self->get_method('AFTER_PLUGIN')) {
    $pre->body->($other, $self);
  }
};

1;
