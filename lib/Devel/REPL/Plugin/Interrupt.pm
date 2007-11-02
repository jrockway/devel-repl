package Devel::REPL::Plugin::Interrupt;

use Moose::Role;
use namespace::clean -except => [ 'meta' ];

around 'eval' => sub {
    my $orig = shift;
    my ($self, $line) = @_;

    local $SIG{INT} = sub {
        die "Interrupted.\n";
    };

    return $self->$orig($line);
};

1;

