package Devel::REPL;

use Term::ReadLine;
use Moose;
use namespace::clean -except => [ 'meta' ];
use 5.008001; # backwards compat, doesn't warn like 5.8.1

our $VERSION = '1.002001'; # 1.2.1

with 'MooseX::Object::Pluggable';

use Devel::REPL::Error;

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
  while ($self->run_once_safely) {
    # keep looping
  }
}

sub run_once_safely {
  my ($self, @args) = @_;

  my $ret = eval { $self->run_once(@args) };

  if ($@) {
    my $error = $@;
    eval { $self->print("Error! - $error\n"); };
    return 1;
  } else {
    return $ret;
  }
}

sub run_once {
  my ($self) = @_;

  my $line = $self->read;
  return unless defined($line); # undefined value == EOF

  my @ret = $self->formatted_eval($line);

  $self->print(@ret);

  return 1;
}

sub formatted_eval {
  my ( $self, @args ) = @_;

  my @ret = $self->eval(@args);

  return $self->format(@ret);
}

sub format {
  my ( $self, @stuff ) = @_;

  if ( $self->is_error($stuff[0]) ) {
    return $self->format_error(@stuff);
  } else {
    return $self->format_result(@stuff);
  }
}

sub format_result {
  my ( $self, @stuff ) = @_;

  return @stuff;
}

sub format_error {
  my ( $self, $error ) = @_;
  return $error->stringify;
}

sub is_error {
  my ( $self, $thingy ) = @_;
  blessed($thingy) and $thingy->isa("Devel::REPL::Error");
}

sub read {
  my ($self) = @_;
  return $self->term->readline($self->prompt);
}

sub eval {
  my ($self, $line) = @_;
  my $compiled = $self->compile($line);
  return $compiled unless defined($compiled) and not $self->is_error($compiled);
  return $self->execute($compiled);
}

sub compile {
  my ( $_REPL, @args ) = @_;
  my $compiled = eval $_REPL->wrap_as_sub(@args);
  return $_REPL->error_return("Compile error", $@) if $@;
  return $compiled;
}

sub wrap_as_sub {
  my ($self, $line, %args) = @_;
  return qq!sub {\n!. ( $args{no_mangling} ? $line : $self->mangle_line($line) ).qq!\n}\n!;
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
  return Devel::REPL::Error->new( type => $type, message => $error );
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
