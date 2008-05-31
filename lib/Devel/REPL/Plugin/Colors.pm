package Devel::REPL::Plugin::Colors;

use Devel::REPL::Plugin;
use Term::ANSIColor;
use namespace::clean -except => [ 'meta' ];

has normal_color => (
  is => 'rw', lazy => 1,
  default => 'green',
);

has error_color => (
  is => 'rw', lazy => 1,
  default => 'bold red',
);

around format_error => sub {
  my $orig = shift;
  my $self = shift;
  return color($self->error_color)
       . $orig->($self, @_)
       . color('reset');
};

# we can't just munge @_ because that screws up DDS
around format_result => sub {
  my $orig = shift;
  my $self = shift;
  no warnings 'uninitialized';
  return join "", (
    color($self->normal_color),
    $orig->($self, @_),
    color('reset'),
  );
};

# make arbitrary warns colored -- somewhat difficult because warn doesn't
# get $self, so we localize $SIG{__WARN__} during eval so it can get
# error_color

sub _wrap_warn {
  my $orig = shift;
  my $self = shift;

  local $SIG{__WARN__} = sub {
    my $warning = shift;
    chomp $warning;
    warn color($self->error_color || 'bold red')
       . $warning
       . color('reset')
       . "\n";
  };

  $orig->($self, @_);
};

around compile => \&_wrap_warn;
around execute => \&_wrap_warn;

1;

__END__

=head1 NAME

Devel::REPL::Plugin::Colors - add color to return values, warnings, and errors

=head1 SYNOPSIS

    #!/usr/bin/perl 

    use lib './lib';
    use Devel::REPL;

    my $repl = Devel::REPL->new;
    $repl->load_plugin('LexEnv');
    $repl->load_plugin('History');
    $repl->load_plugin('Colors');
    $repl->run;

=head1 DESCRIPTION

Colors are very pretty.

This plugin causes certain prints, warns, and errors to be colored. Generally
the return value(s) of each line will be colored green (you can override this
by setting C<< $_REPL->normal_color >> in your rcfile). Warnings and
compile/runtime errors will be colored with C<< $_REPL->error_color >>. This
plugin uses L<Term::ANSIColor>, so consult that module for valid colors. The
defaults are actually 'green' and 'bold red'.

=head1 SEE ALSO

C<Devel::REPL>

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail dot com> >>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Shawn M Moore

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
