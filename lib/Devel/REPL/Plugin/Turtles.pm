package Devel::REPL::Plugin::Turtles;
use Moose::Role;
use namespace::clean -except => [ 'meta' ];

around 'eval' => sub {
    my $next = shift;
    my ($self, $line) = @_;
    if ($line =~ /^#(.*)/) {
        return $next->($self, ('$_REPL->' . $1 . '; return();'));
    }
    else {
        return $next->($self, $line);
    }
    
};

1;
