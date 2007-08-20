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

    # init the completion with an arrayref (could be the Perl built-ins)
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

# wrap the read method so we save in the completion list 
# each variable declaration
around 'read' => sub {
  my $orig = shift;
  my ($self, @args) = @_;
  my $line = $self->$orig(@args);
  if (defined $line) {
      if ($line =~ /\s*[\$\%\@](\S+)\s*=/) {
          my $str = $1;
          $self->push_completion($str);
      }
  }
  return $line;
};

# wrap the eval one to catch each 'use' statement in order to 
# load the namespace in the completion list (module functions and friends)
# we do that around the eval method cause we want the module to be actually loaded.
around 'eval' => sub {
    my $orig = shift;
    my ($self, $line) = @_;
    my @ret = $self->$orig($line);
    if ($line =~ /use\s+(\S+)/) {
        my $module = $1;
        foreach my $keyword (keys %{$self->get_namespace($module)}) {
            $self->push_completion($keyword);
        }
    }
    return @ret;
};

1;
