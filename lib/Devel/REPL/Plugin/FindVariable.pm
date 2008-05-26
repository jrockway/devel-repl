package Devel::REPL::Plugin::FindVariable;

use Moose::Role;
use namespace::clean -except => [ 'meta' ];

sub find_variable {
    my ($self, $name) = @_;

    my $sigil = $name =~ s/^([\$\@\%\&\*])// ? $1 : '';

    my $default_package = $self->can('current_package')
                        ? $self->current_package
                        : 'main';
    my $package = $name =~ s/^(.*)(::|')// ? $1 : $default_package;

    my $meta = Class::MOP::Class->initialize($package);

    return unless $meta->has_package_symbol("$sigil$name");
    $meta->get_package_symbol("$sigil$name");
}

1;

