package Devel::REPL::Backend::Default;
use Moose::Role;
use Devel::REPL::Error;
use namespace::autoclean;

with 'Devel::REPL::Backend::API';

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

1;
