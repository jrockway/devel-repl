package Devel::REPL::Plugin::Timing;

use Devel::REPL::Plugin;
use Time::HiRes 'time';
use namespace::clean -except => [ 'meta' ];

around 'eval' => sub {
    my $orig = shift;
    my ($self, $line) = @_;

    my @ret;
    my $start = time;

    if (wantarray) {
        @ret = $self->$orig($line);
    }
    else {
        $ret[0] = $self->$orig($line);
    }

    $self->print("Took " . (time - $start) . " seconds.\n");
    return @ret;
};

1;

__END__

=head1 NAME

Devel::REPL::Plugin::Timing - display execution times

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail dot com> >>

=cut

