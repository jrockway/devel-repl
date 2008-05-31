# Original comment:
#
# Adds a newline after print. Some readlines need it some don't. I guess
# we should clarify whether this is a bug and if so whose bug at some point
# but this'll do for now ;)

package Devel::REPL::Plugin::NewlineHack;

use Devel::REPL::Plugin;
use namespace::clean -except => [ 'meta' ];

warn <<EOW;
No longer required, extra newline automatically produced for Gnu readline
implementation by Devel::REPL's print() method.

This plugin will be removed at some point; please remove it from your config.
EOW

1;

__END__

=head1 NAME

Devel::REPL::Plugin::NewlineHack - (deprecated)

=cut

