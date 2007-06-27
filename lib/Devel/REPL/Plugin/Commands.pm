package Devel::REPL::Plugin::Commands;

use Devel::REPL::Plugin;
use Scalar::Util qw(weaken);

use namespace::clean -except => [ 'meta' ];
use vars qw($COMMAND_INSTALLER);

has 'command_set' => (
  is => 'ro', required => 1,
  lazy => 1, default => sub { {} }
);

sub BEFORE_PLUGIN {
  my ($self) = @_;
  unless ($self->can('setup_commands')) {
    $self->meta->add_method('setup_commands' => sub {});
  }
}

sub AFTER_PLUGIN {
  my ($self) = @_;
  $self->setup_commands;
}

after 'setup_commands' => sub {
  my ($self) = @_;
  weaken($self);
  $self->command_set->{load_plugin} = sub { $self->load_plugin(@_); };
};

sub command_installer {
  my ($self) = @_;
  my %command_set = %{$self->command_set};
  return sub {
    my $package = shift;
    foreach my $command (keys %command_set) {
      no strict 'refs';
      no warnings 'redefine';
      *{"${package}::${command}"} = $command_set{$command};
    }
  };
}

around 'mangle_line' => sub {
  my ($orig, $self) = (shift, shift);
  my ($line) = @_;
  my $name = '$'.__PACKAGE__.'::COMMAND_INSTALLER';
  return qq{BEGIN { ${name}->(__PACKAGE__) }\n}.$self->$orig(@_);
};

around 'compile' => sub {
  my ($orig, $self) = (shift, shift);
  local $COMMAND_INSTALLER = $self->command_installer;
  $self->$orig(@_);
};

1;
