package Devel::REPL::Plugin::Completion;

use Moose::Role;
use namespace::clean -except => [ 'meta' ];


# push the given string in the completion list
sub push_completion
{
    my ($self, $string) = @_;
    $self->term->Attribs->{completion_entry_function} = 
        $self->term->Attribs->{list_completion_function};
    push @{$self->term->Attribs->{completion_word}}, $string;
};

# return the namespace of the module given
sub get_namespace
{
    my ($self, $module) = @_;
    my $namespace;
    eval '$namespace = \%'.$module.'::';
    return $namespace;
}

# we wrap the run method to init the completion list 
# with filenames found in the current dir and init 
# the completion list.
# yes, this is our 'init the plugin' stuff actually
sub BEFORE_PLUGIN 
{
    my ($self) = @_;
    # set the completion function
    $self->term->Attribs->{completion_entry_function} = 
        $self->term->Attribs->{list_completion_function};
    $self->term->Attribs->{completion_word} = [];

    # now put each file in curdir in the completion list
    my $curdir = File::Spec->curdir();
    if (opendir(CURDIR, $curdir)) {
        while (my $file = readdir(CURDIR)) {
            next if $file =~ /^\.+$/; # we skip "." and ".."
                $self->push_completion($file);
        }
    }
    closedir(CURDIR);
}

# wrap the eval one to catch each 'use' statement in order to 
# load the namespace in the completion list (module functions and friends)
# we do that around the eval method cause we want the module to be actually loaded.
around 'eval' => sub {
    my $orig = shift;
    my ($self, $line) = @_;
    my @ret = $self->$orig($line);
    
    # the namespace of the loaded module
    if ($line =~ /\buse\s+(\S+)/) {
        my $module = $1;
        foreach my $keyword (keys %{$self->get_namespace($module) || {}}) {
            $self->push_completion($keyword);
        }
    }

    # parses the lexical environment for new variables to add to 
    # the completion list
    my $lex = $self->lexical_environment;
    foreach my $var (keys %{$lex->get_context('_')}) {
        $var = substr($var, 1); # we drop the variable idiom as it confuses the completion
        $self->push_completion($var) unless 
            grep /^${var}$/, @{$self->term->Attribs->{completion_word}};
    }

    return @ret;
};

1;
