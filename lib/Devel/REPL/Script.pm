package Devel::REPL::Script;

use Moose;
use Devel::REPL;
use File::HomeDir;
use File::Spec;
use vars qw($CURRENT_SCRIPT);
use namespace::clean -except => [ qw(meta) ];

with 'MooseX::Getopt';

has 'rcfile' => (
  is => 'ro', isa => 'Str', required => 1, default => sub { 'repl.rc' },
);

has 'profile' => (
  is => 'ro', isa => 'Str', required => 1, default => sub { 'Default' },
);

has '_repl' => (
  is => 'ro', isa => 'Devel::REPL', required => 1,
  default => sub { Devel::REPL->new() }
);

sub BUILD {
  my ($self) = @_;
  $self->load_profile($self->profile);
  $self->load_rcfile($self->rcfile);
}

sub load_profile {
  my ($self, $profile) = @_;
  $profile = "Devel::REPL::Profile::${profile}" unless $profile =~ /::/;
  Class::MOP::load_class($profile);
  $profile->new->apply_profile($self->_repl);
}

sub load_rcfile {
  my ($self, $rc_file) = @_;

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
  my ($self, $data) = @_;
  local $CURRENT_SCRIPT = $self;
  $self->_repl->eval($data);
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

sub current {
  confess "->current should only be called as class method" if ref($_[0]);
  confess "No current instance (valid only during rc parse)"
    unless $CURRENT_SCRIPT;
  return $CURRENT_SCRIPT;
}

1;
