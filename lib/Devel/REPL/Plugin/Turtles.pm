package Devel::REPL::Plugin::Turtles;
use Devel::REPL::Plugin;

use Scalar::Util qw(reftype);

use MooseX::AttributeHelpers;

use namespace::clean -except => [ 'meta' ];

has default_command_prefix => (
  isa => "RegexpRef",
  is  => "rw",
  default => sub { qr/\#/ },
);

has turtles_matchers => (
  metaclass => "Collection::Array",
  isa => "ArrayRef[RegexpRef|CodeRef]",
  is  => "rw",
  lazy => 1,
  default => sub { my $prefix = shift->default_command_prefix; [qr/^ $prefix (\w+) \s* (.*) /x] },
  provides => {
    unshift => "add_turtles_matcher",
  },
);

around 'formatted_eval' => sub {
  my $next = shift;
  my ($self, $line, @args) = @_;

  if ( my ( $command, @rest ) = $self->match_turtles($line) ) {
    my $method = "command_$command";
    my $expr_method = "expr_$method";

    if ( my $expr_code = $self->can($expr_method) ) {
      if ( my $read_more = $self->can("continue_reading_if_necessary") ) {
        push @rest, $self->$read_more(pop @rest);
      }
      $self->$expr_code($next, @rest);
    } elsif ( my $cmd_code = $self->can($method) ) {
      return $self->$cmd_code($next, @rest);
    } else {
      unless ( $line =~ /^\s*#/ ) { # special case for comments
        return $self->format($self->error_return("REPL Error", "Command '$command' does not exist"));
      }
    }
  } else {
    return $self->$next($line, @args);
  }
};

sub match_turtles {
  my ( $self, $line ) = @_;

  foreach my $thingy ( @{ $self->turtles_matchers } ) {
    if ( reftype $thingy eq 'CODE' ) {
      if ( my @res = $self->$thingy($line) ) {
        return @res;
      }
    } else {
      if ( my @res = ( $line =~ $thingy ) ) {
        return @res;
      }
    }
  }

  return;
}

1;

__END__

=head1 NAME

Devel::REPL::Plugin::Turtles - Generic command creation using a read hook

=head1 DESCRIPTION

By default, this plugin allows calling commands using a read hook
to detect a default_command_prefix followed by the command name,
say MYCMD as an example.  The actual routine to call for the
command is constructed by looking for subs named 'command_MYCMD'
or 'expr_MYCMD' and executing them.

=head2 NOTE

The C<default_command_prefix> is C<qr/\#/> so care must be taken
if other uses for that character are needed (e.g., '#' for the
shell escape character in the PDL shell.

=cut

