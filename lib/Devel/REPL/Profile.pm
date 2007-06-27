package Devel::REPL::Profile;

use Moose::Role;
use namespace::clean -except => [ 'meta' ];

requires 'apply_profile';

1;
