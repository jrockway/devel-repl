package Devel::REPL::Plugin::Nopaste;

use Moose::Role;
use MooseX::AttributeHelpers;
use namespace::clean -except => [ 'meta' ];

with 'Devel::REPL::Plugin::Turtles';

has complete_session => (
    metaclass => 'String',
    is        => 'rw',
    isa       => 'Str',
    default   => '',
    provides  => {
        append => 'add_to_session',
    },
);

around eval => sub {
    my $orig = shift;
    my $self = shift;
    my $line = shift;

    my @ret = $orig->($self, $line, @_);

    # prepend each line with #
    $line =~ s/^/# /mg;

    my $step = $line . "\n"
             . join("\n", @ret)
             . "\n\n";

    $self->add_to_session($step);

    return @ret;
};

sub command_nopaste {
    my $self = shift;

    require App::Nopaste;
    return App::Nopaste->nopaste(
        text => $self->complete_session,
        desc => "Devel::REPL session",
        lang => "perl",
    );
}

1;

