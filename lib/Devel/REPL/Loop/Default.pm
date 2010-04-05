package Devel::REPL::Loop::Default;
use Moose::Role;
use namespace::autoclean;

with 'Devel::REPL::Loop::API';

sub run {
  my ($self) = @_;
  while ($self->run_once_safely) {
    # keep looping
  }
}

sub run_once_safely {
  my ($self, @args) = @_;

  my $ret = eval { $self->run_once(@args) };

  if ($@) {
    my $error = $@;
    eval { $self->frontend->print("Error! - $error\n"); };
    return 1;
  } else {
    return $ret;
  }
}

sub run_once {
  my ($self) = @_;

  my $line = $self->frontend->read;
  return unless defined($line); # undefined value == EOF

  my @ret = $self->backend->formatted_eval($line);

  $self->frontend->print(@ret);

  return 1;
}

1;
