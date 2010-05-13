# First cut at using the readline history directly rather than reimplementing
# it. It does save history but it's a little crappy; still playing with it ;)
#
# epitaph, 22nd April 2007

package Devel::REPL::Plugin::ReadLineHistory;

use Devel::REPL::Plugin;
use File::HomeDir;
use File::Spec;

my $hist_file = $ENV{PERLREPL_HISTFILE} ||
    File::Spec->catfile(File::HomeDir->my_home, '.perlreplhist');

# HISTLEN should probably be in a config file to stop people accidentally
# truncating their history if they start the program and forget to set
# PERLREPL_HISTLEN
my $hist_len=$ENV{PERLREPL_HISTLEN} || 100;

around 'run' => sub {
   my $orig=shift;
   my ($self, @args)=@_;
   if ($self->term->ReadLine eq 'Term::ReadLine::Gnu') {
      $self->term->stifle_history($hist_len);
   }
   if ($self->term->ReadLine eq 'Term::ReadLine::Perl') {
      $self->term->Attribs->{MaxHistorySize} = $hist_len;
   }
   if (-f($hist_file)) {
      if ($self->term->ReadLine eq 'Term::ReadLine::Gnu') {
         $self->term->ReadHistory($hist_file);
      }
      if ($self->term->ReadLine eq 'Term::ReadLine::Perl') {
         open HIST, $hist_file or die "ReadLineHistory: could not open $hist_file: $!\n";
         while (my $line = <HIST>) {
            chomp $line;
            $self->term->addhistory($line);
         }
         close HIST;
      }
   }
   $self->term->Attribs->{do_expand}=1;
   $self->$orig(@args);
   if ($self->term->ReadLine eq 'Term::ReadLine::Gnu') {
      $self->term->WriteHistory($hist_file) ||
      $self->print("warning: failed to write history file $hist_file");
   }
   if ($self->term->ReadLine eq 'Term::ReadLine::Perl') {
      my @lines = $self->term->GetHistory() if $self->term->can('GetHistory');
      if( open HIST, ">$hist_file" ) {
         print HIST join("\n",@lines);
         close HIST;
      } else {
         $self->print("warning: unable to WriteHistory to $hist_file");
      }
   }
};

1;

__END__

=head1 NAME

Devel::REPL::Plugin::ReadLineHistory - Integrate history with the facilities provided by L<Term::ReadLine>

=cut

