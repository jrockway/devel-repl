package Devel::REPL::Plugin::Turtles;
use Moose::Role;

around 'eval' => sub {
    my $next = shift;
    my ($self, $line) = @_;
    if ($line =~ /^#(.*)/) {
        return $next->($self, ('$self->' . $1 . '; return();'));
    }
    else {
        return $next->($self, $line);
    }
    
};

1;