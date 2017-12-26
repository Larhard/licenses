#!/usr/bin/env perl

use strict;
use warnings;
use v5.20;

use Cwd qw/abs_path/;
use File::Basename qw/dirname fileparse/;
use File::Spec;

use Text::Wrap;

my $licenses_dir = (dirname abs_path $0) . "/licenses";
my @licenses = glob "$licenses_dir/*";
for (@licenses) {
    $_ = fileparse $_;
}

if ($#ARGV != 0) {
    die "possible licenses: " . join ", ", @licenses
}

my $license_path = File::Spec->catfile($licenses_dir, $ARGV[0]);

if (not -e $license_path) {
    die "possible licenses: " . join ", ", @licenses;
}

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;

my $username = `git config user.name`;
chomp $username;
my $USERNAME = uc $username;

my $email = `git config user.email`;
chomp $email;

open my $fh, "<", $license_path;
my @lines = <$fh>;
close $fh;

for (@lines) {
    chomp;

    s/<year>/$year/g;
    s/<copyright holder>/$username <$email>/g;
    s/<organization>/$username/g;
    s/<COPYRIGHT HOLDER>/$USERNAME/g;
}

for my $line (@lines) {
    my @line = ($line);

    my $firstindent = "";
    my $nextindent = $line;
    $nextindent =~ s/[^\s*].*$//;
    $nextindent =~ s/\S/ /g;

    print wrap $firstindent, $nextindent, @line;
    print "\n";
}
