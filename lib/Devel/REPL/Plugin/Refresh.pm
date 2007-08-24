package Devel::REPL::Plugin::Refresh;

use Moose::Role;
use namespace::clean -except => [ 'meta' ];
use Module::Refresh;

# before evaluating the code, ask Module::Refresh to refresh
# the modules that have changed
around 'eval' => sub {
    my $orig = shift;
    my ($self, $line) = @_;

    # first refresh the changed modules
    Module::Refresh->refresh;

    # the eval the code
    return $self->$orig($line);
};

1;
