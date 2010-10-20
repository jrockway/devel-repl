package Devel::REPL::Plugin::ResultNames;
use Moose::Role;
use namespace::autoclean;

use Hash::Util::FieldHash qw(fieldhash);
use Scalar::Util qw(refaddr);

has 'var_type_counts' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { +{} },
);

has 'seen_vals' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub {
        my %seen_vals;
        fieldhash %seen_vals;
        return \%seen_vals;
    },
);

has 'seen_vars' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { +{} },
);

sub name_for {
    my ($self, $thing) = @_;

    die q{can't name nonrefs} unless ref $thing;

    return $self->seen_vals->{$thing}
      if exists $self->seen_vals->{$thing};

    my $name;
    if($self->can('lexical_environment')){
        my %varhash = %{$self->lexical_environment->{context}{_}};
        for my $var (keys %varhash) {
            my $val = $varhash{$var};
            $self->seen_vars->{$var} = 1;
            $self->seen_vals->{$val} = $var if ref $val; # remember this, so we
                                                         # don't have to iterate
                                                         # again
            no warnings 'uninitialized';
            $name = $var if refaddr($val) == refaddr($thing);
        }
    }
    return $name if $name;

    $name = ref $thing || 'R';
    $name =~ s/::/_/g;

    my $count;
    do {
        $count = ++$self->var_type_counts->{$name};
    } while ($self->seen_vars->{"\$$name$count"});

    $self->seen_vars->{"\$$name$count"} = 1;
    $self->seen_vals->{$thing} = "\$$name$count";
    return "\$$name$count";
}

around 'eval' => sub {
    my ($orig, $self, @args) = @_;
    my @result = $self->$orig(@args);
    my $result = @result > 1 ? [@result] : $result[0];
    $self->name_for($result) if ref $result;
    return @result;
};

1;
