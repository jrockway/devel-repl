package Devel::REPL::Plugin::DDS;

use Devel::REPL::Plugin;
use Data::Dump::Streamer ();

around 'format_result' => sub {
   my $orig = shift;
   my $self = shift;
   my @to_dump = @_;
   my $out;
   if (@to_dump != 1 || ref $to_dump[0]) {
      if (@to_dump == 1 && overload::Method($to_dump[0], '""')) {
         $out = "@to_dump";
      } else {
         my $dds = Data::Dump::Streamer->new;
         $dds->Freezer(sub { "$_[0]"; });
         $dds->Data(@to_dump);
         $out = $dds->Out;
      }
   } else {
      $out = $to_dump[0];
   }
   $self->$orig($out);
};

1;

__END__

=head1 NAME

Devel::REPL::Plugin::DDS - Format results with Data::Dump::Streamer

=head1 SYNOPSIS

 # in your re.pl file:
 use Devel::REPL;
 my $repl = Devel::REPL->new;
 $repl->load_plugin('DDS');
 $repl->run;

 # after you run re.pl:
 $ map $_*2, ( 1,2,3 )
 $ARRAY1 = [
             2,
             4,
             6
           ];

 $

=cut

