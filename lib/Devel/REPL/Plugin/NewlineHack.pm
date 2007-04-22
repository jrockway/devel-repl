# Adds a newline after print. Some readlines need it some don't. I guess
# we should clarify whether this is a bug and if so whose bug at some point
# but this'll do for now ;)

package Devel::REPL::Plugin::NewlineHack;

use Moose::Role;
use namespace::clean -except => [ 'meta' ];

after 'print' => sub {
  # not fussed about args
  my ($self) = @_;
  my $fh = $self->out_fh;
  print $fh "\n";
};

1;

