package Devel::REPL::Script;

use Moose;
use Devel::REPL;
use File::HomeDir;
use File::Spec;
use namespace::clean -except => [ qw(meta) ];

with 'MooseX::Getopt';

has 'rcfile' => (
  is => 'ro', isa => 'Str', required => 1, default => sub { 'repl.rc' },
);

has '_repl' => (
  is => 'ro', isa => 'Devel::REPL', required => 1,
  default => sub { Devel::REPL->new() }
);

sub BUILD {
  my ($self) = @_;
  $self->load_rcfile;
}

sub load_rcfile {
  my ($self) = @_;

  my $rc_file = $self->rcfile;

  # plain name => ~/.re.pl/${rc_file}
  if ($rc_file !~ m!/!) {
    $rc_file = File::Spec->catfile(File::HomeDir->my_home, '.re.pl', $rc_file);
  }

  if (-r $rc_file) {
    open RCFILE, '<', $rc_file || die "Couldn't open ${rc_file}: $!";
    my $rc_data;
    { local $/; $rc_data = <RCFILE>; }
    close RCFILE; # Don't care if this fails
    $self->eval_rcdata($rc_data);
    warn "Error executing rc file ${rc_file}: $@\n" if $@;
  }
}

sub eval_rcdata {
  my $_REPL = $_[0]->_repl;
  eval $_[1];
}

sub run {
  my ($self) = @_;
  $self->_repl->run;
}

sub import {
  my ($class, @opts) = @_;
  return unless (@opts == 1 && $opts[0] eq 'run');
  $class->new_with_options->run;
}

1;
