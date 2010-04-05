package Devel::REPL::Frontend::Terminal;
use Moose::Role;
use namespace::autoclean;

use Term::ReadLine;

with 'Devel::REPL::Frontend::API';

has 'term' => (
  is => 'rw',
  lazy => 1,
  default => sub { Term::ReadLine->new('Perl REPL') },
);

has 'prompt' => (
  is => 'rw',
  default => sub { '$ ' },
);

has 'out_fh' => (
  is => 'rw',
  lazy => 1,
  default => sub { shift->term->OUT || \*STDOUT; },
);

sub read {
  my ($self) = @_;
  return $self->term->readline($self->prompt);
}

sub print {
  my ($self, @ret) = @_;
  my $fh = $self->out_fh;
  no warnings 'uninitialized';
  print $fh "@ret";
  print $fh "\n" if $self->term->ReadLine =~ /Gnu/;
}

1;
