package Devel::REPL::Plugin::DumpHistory;

use Devel::REPL::Plugin;
use namespace::clean -except => [ 'meta' ];

## Seems to be a sequence issue with requires
# requires qw{ history }; 

around 'read' => sub {
  my $orig = shift;
  my ($self, @args) = @_;

  my $line = $self->$orig(@args);
  if (defined $line) {
    if ($line =~ m/^:dump ?(.*)$/) {
      my $file = $1;
      $self->print_history($file);
      return '';
    }
  }
  return $line;
};

sub print_history {
    my ( $self, $file ) = @_;

    if ($file) {
        open( my $fd, ">>", $file )
            or do { warn "Couldn't open '$file': $!\n"; return; };
        print $fd "$_\n" for ( @{ $self->history } );
        $self->print( sprintf "Dumped %d history lines to '$file'\n",
            scalar @{ $self->history } );
        close $fd;
    } else {
        $self->print("$_\n") for ( @{ $self->history } );
    }
    return 1;
}

1;

__END__

=head1 NAME

Devel::REPL::Plugin::DumpHistory - Plugin for Devel::REPL to save or print
the history.

=head1 SYNOPSIS

    #!/usr/bin/perl 

    use lib './lib';
    use Devel::REPL;

    my $repl = Devel::REPL->new;
    $repl->load_plugin('LexEnv');
    $repl->load_plugin('History');
    $repl->load_plugin('DumpHistory');
    $repl->run;

=head1 DESCRIPTION

Plugin that adds the C<:dump> and C<:dump file_name> commands to the 
repl which will print the history to STDOUT or append the history to the
file given.

=head1 SEE ALSO

C<Devel::REPL>

=head1 AUTHOR

mgrimes, E<lt>mgrimes at cpan dot org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by mgrimes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
