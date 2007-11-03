package Devel::REPL::Plugin::Timing;

use Moose::Role;
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

