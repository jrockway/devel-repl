package Devel::REPL;

use Term::ReadLine;
use Moose;
use namespace::clean -except => [ 'meta' ];
use 5.8.1; # might work with earlier perls but probably not

our $VERSION = '1.002001'; # 1.2.1

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
  my @ret = $self->eval($line);
  eval {
    $self->print(@ret);
  };
  if ($@) {
    my $error = $@;
    eval { $self->print("Error printing! - $error\n"); };
  }
  return 1;
}

sub read {
  my ($self) = @_;
  return $self->term->readline($self->prompt);
}

sub eval {
  my ($self, $line) = @_;
  my ($to_exec, @rest) = $self->compile($line);
  return @rest unless defined($to_exec);
  my @ret = $self->execute($to_exec);
  return @ret;
}

sub compile {
  my $_REPL = shift;
  my $compiled = eval $_REPL->wrap_as_sub($_[0]);
  return (undef, $_REPL->error_return("Compile error", $@)) if $@;
  return $compiled;
}

sub wrap_as_sub {
  my ($self, $line) = @_;
  return qq!sub {\n!.$self->mangle_line($line).qq!\n}\n!;
}

sub mangle_line {
  my ($self, $line) = @_;
  return $line;
}

sub execute {
  my ($self, $to_exec, @args) = @_;
  my @ret = eval { $to_exec->(@args) };
  return $self->error_return("Runtime error", $@) if $@;
  return @ret;
}

sub error_return {
  my ($self, $type, $error) = @_;
  return "${type}: ${error}";
}

sub print {
  my ($self, @ret) = @_;
  my $fh = $self->out_fh;
  no warnings 'uninitialized';
  print $fh "@ret";
  print $fh "\n" if $self->term->ReadLine =~ /Gnu/;
}

=head1 NAME

Devel::REPL - a modern perl interactive shell

=head1 SYNOPSIS

  my $repl = Devel::REPL->new;
  $repl->load_plugin($_) for qw(History LexEnv);
  $repl->run

Alternatively, use the 're.pl' script installed with the distribution

  system$ re.pl

=head1 AUTHOR

Matt S Trout - mst (at) shadowcatsystems.co.uk (L<http://www.shadowcatsystems.co.uk/>)

=head1 CONTRIBUTORS

=over 4

=item Stevan Little - stevan (at) iinteractive.com

=item Alexis Sukrieh - sukria+perl (at) sukria.net

=item epitaph

=item mgrimes - mgrimes (at) cpan dot org

=item Shawn M Moore - sartak (at) gmail.com

=back

=head1 LICENSE

This library is free software under the same terms as perl itself

=cut

1;
