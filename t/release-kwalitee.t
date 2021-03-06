#!perl

use strict;
use warnings;
use Test::More;   # needed to provide plan.

plan skip_all => "These tests are for authors only!" unless $ENV{AUTHOR_TESTING} or $ENV{RELEASE_TESTING};

eval { require Test::Kwalitee };
plan skip_all => "Test::Kwalitee required for testing kwalitee: $@" if $@;

eval "use Test::Kwalitee";
