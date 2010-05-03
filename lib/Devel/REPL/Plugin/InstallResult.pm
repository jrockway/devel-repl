package Devel::REPL::Plugin::InstallResult;
use Moose::Role;
use namespace::autoclean;

# with 'Devel::REPL::Plugin::LexEnv', 'Devel::REPL::Plugin::ResultNames';

around 'eval' => sub {
    my ($orig, $self, @args) = @_;
    my @result = $self->$orig(@args);
    my $result = @result > 1 ? [@result] : $result[0];

    if (ref $result){
        $self->lexical_environment->{context}{_}{$self->name_for($result)} = $result;
    }

    return $result;
};

1;
