#! /usr/bin/perl -w

use strict;

sub help {
    print STDERR "USAGE: $0 <c|x|t><f> <text tar file> < filelist\n";
    exit 1;
}

my $command = shift || help;
my $mode = undef;
my $file = shift || help;

($command =~ m/^c/) && do {
    my @files = (<>);
    &create($file, @files);
    exit 0;
};
($command =~ m/^x/) && do {
    &extract($file);
    exit 0;
};
($command =~ m/^t/) && do {
    &list($file);
    exit 0;
};

help if (!defined $mode);
exit 0;

sub create {
    my ($file, @files) = @_;
    open(TTFILE, ">$file") || do {
        print STDERR ">$file: $!\n";
        return 0;
    };
    foreach my $currentFile (@files) {
        open(CFILE, "$currentFile") || do {
            print STDERR "$currentFile: $!\n";
            next; # ignore
        };
        print TTFILE "#?#?#?#?#? $currentFile";
        print "a $currentFile";
        {
            local(undef $/);
            print TTFILE <CFILE>;
        }
        close(CFILE);
    }
    close(TTFILE);
    return 1;
}

sub list {
    my ($file) = @_;
    open (FILE, $file) || do {
        print STDERR "$file: $!\n";
        return 0;
    }; 
    while (defined (my $line = <FILE>)) {
        if ($line =~ /^#\?#\?#\?#\?#\? ([\S]+)/) {
            my $currentFile = $1;
            print "t $currentFile\n";
        }
    }
    close(FILE);
    return 1;
}

sub extract {
    my ($file) = @_;
    my $opened = 0;
    open (FILE, $file) || do {
        print STDERR "$file: $!\n";
        return 0;
    }; 
    while (defined (my $line = <FILE>)) {
        if ($line =~ /^#\?#\?#\?#\?#\? ([\S]+)/) {
            my $currentFile = $1;
            close(CFILE);
            $opened = 0;
            open(CFILE, ">$currentFile") || do {
                print STDERR ">$currentFile: $!\n";
                next; # ignore
            };
            print "x $currentFile\n";
            $opened = 1;
        } else {
            if ($opened) {
                print CFILE $line;
            }
        }
    }
    close(CFILE);
    close(FILE);
    return 1;
}
