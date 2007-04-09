package Devel::REPL;

use Term::ReadLine;
use Moose;
use namespace::clean;

with 'MooseX::Object::Pluggable';

has 'term' => (
  is => 'rw', required => 1,
  default => sub { Term::ReadLine->new('Perl REPL') }
);

has 'prompt' => (
  is => 'rw', required => 1,
  default => sub { '$ ' }
);

has 'out_fh' => (
  is => 'rw', required => 1, lazy => 1,
  default => sub { shift->term->OUT || \*STDOUT; }
);

sub run {
  my ($self) = @_;
  while ($self->run_once) {
    # keep looping
  }
}

sub run_once {
  my ($self) = @_;
  my $line = $self->read;
  return unless defined($line); # undefined value == EOF
  my @ret = $self->execute($line);
  $self->print(@ret);
  return 1;
}

sub read {
  my ($self) = @_;
  return $self->term->readline($self->prompt);
}

sub execute {
  my ($self, $to_exec) = @_;
  my @ret = eval $to_exec;
  @ret = ("ERROR: $@") if $@;
  return @ret;
}

sub print {
  my ($self, @ret) = @_;
  my $fh = $self->out_fh;
  print $fh "@ret";
}

1;
