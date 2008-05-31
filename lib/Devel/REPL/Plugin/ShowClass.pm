package Devel::REPL::Plugin::ShowClass;
use Devel::REPL::Plugin;
use namespace::clean -except => [ 'meta' ];

has 'metaclass_cache' => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {{}}
);

before 'eval' => sub {
    my $self = shift;
    $self->update_metaclass_cache;
};

after 'eval' => sub {
    my $self = shift;
    
    my @metas_to_show;
    
    foreach my $class (Class::MOP::get_all_metaclass_names()) {
        unless (exists $self->metaclass_cache->{$class}) {
            push @metas_to_show => Class::MOP::get_metaclass_by_name($class)
        }
    }    
    
    $self->display_class($_) foreach @metas_to_show;
    
    $self->update_metaclass_cache;
};

sub update_metaclass_cache {
    my $self = shift;
    foreach my $class (Class::MOP::get_all_metaclass_names()) {
        $self->metaclass_cache->{$class} = (
            ("" . Class::MOP::get_metaclass_by_name($class))
        );
    }    
}

sub display_class {
    my ($self, $meta) = @_;
    $self->print('package ' . $meta->name . ";\n\n");
    $self->print('extends (' . (join ", " => $meta->superclasses) . ");\n\n") if $meta->superclasses;
    $self->print('with (' . (join ", " => map { $_->name } @{$meta->roles}) . ");\n\n") if $meta->can('roles');    
    foreach my $attr (map { $meta->get_attribute($_) } $meta->get_attribute_list) {
        $self->print('has ' . $attr->name . " => (\n");
        $self->print('    is => ' . $attr->_is_metadata . ",\n")  if $attr->_is_metadata;        
        $self->print('    isa => ' . $attr->_isa_metadata . ",\n") if $attr->_isa_metadata;  
        $self->print('    required => ' . $attr->is_required . ",\n") if $attr->is_required;                
        $self->print('    lazy => ' . $attr->is_lazy . ",\n") if $attr->is_lazy;                        
        $self->print('    coerce => ' . $attr->should_coerce . ",\n") if $attr->should_coerce;                        
        $self->print('    is_weak_ref => ' . $attr->is_weak_ref . ",\n") if $attr->is_weak_ref;                                
        $self->print('    auto_deref => ' . $attr->should_auto_deref . ",\n") if $attr->should_auto_deref;                                        
        $self->print(");\n");
        $self->print("\n");
    }
    foreach my $method_name ($meta->get_method_list) {
        next if $method_name eq 'meta'
             || $meta->get_method($method_name)->isa('Class::MOP::Method::Accessor');
        $self->print("sub $method_name { ... }\n");        
        $self->print("\n");        
    }
    $self->print("1;\n");    
}

1;

__END__

=head1 NAME

Devel::REPL::Plugin::ShowClass - Dump classes initialized with Class::MOP

=cut

