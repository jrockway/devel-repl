package Devel::REPL::Plugin::LexEnv;

use Moose::Role;
use namespace::clean -except => [ 'meta' ];
use Lexical::Persistence;

has 'lexical_environment' => (
  isa => 'Lexical::Persistence',
  is => 'rw',
  required => 1,
  lazy => 1,
  default => sub { Lexical::Persistence->new }
);

around 'mangle_line' => sub {
  my $orig = shift;
  my ($self, @rest) = @_;
  my $line = $self->$orig(@rest);
  my $lp = $self->lexical_environment;
  return join('', map { "my $_;\n" } keys %{$lp->get_context('_')}).$line;
};

around 'execute' => sub {
  my $orig = shift;
  my ($self, $to_exec, @rest) = @_;
  my $wrapped = $self->lexical_environment->wrap($to_exec);
  return $self->$orig($wrapped, @rest);
};

1;
