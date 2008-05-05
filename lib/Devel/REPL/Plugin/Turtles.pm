package Devel::REPL::Plugin::Turtles;
use Moose::Role;
use namespace::clean -except => [ 'meta' ];

around 'eval' => sub {
  my $next = shift;
  my ($self, $line) = @_;
  if ( my ( $command, $rest ) = ( $line =~ /^#(\w+)\s*(.*)/ ) ) {
    if ( my $cont = $self->can("continue_reading_if_necessary") ) {
      $rest = $self->$cont($rest);
    }

    my $method = "command_$command";

    if ( $self->can($method) ) {
      return $self->$method($rest);
    } else {
      return $self->error_return("REPL error", "Command '$command' does not exist");
    }
  }
  else {
    return $next->($self, $line);
  }
};

1;
