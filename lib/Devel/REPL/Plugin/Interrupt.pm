package Devel::REPL::Plugin::Interrupt;

use Devel::REPL::Plugin;
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

__END__

=head1 NAME

Devel::REPL::Plugin::Interrupt - traps SIGINT to kill long-running lines

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail dot com> >>

=cut

