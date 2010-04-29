package Devel::REPL::Plugin::LoadClass;
use Devel::REPL::Plugin;
use namespace::clean -except => [ 'meta' ];

around eval => sub {
    my ($next, $self, @args) = @_;

    my @result = $self->$next(@args);
    my $error = $result[0];

    if(blessed $error &&
       $error->isa('Devel::REPL::Error') &&
       $error->type eq 'Runtime error' &&
       $error->message =~ /perhaps you forgot to load "([^"]+)"\?/){

        eval {
            Class::MOP::load_class($1);
        };
        if($@){
            return @result;
        }

        return $self->$next(@args);
    }

    return @result;
};

1;
