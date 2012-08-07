#!/usr/bin/perl -w
# --
# module-tools/link.pl
#   - script for linking OTRS modules into framework root
# Copyright (C) 2001-2009 OTRS AG, http://otrs.org/
# --
# $Id: link.pl,v 1.14 2009/07/09 10:52:30 bes Exp $
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --

=head1 NAME

link.pl - script for linking OTRS modules into framework root

=head1 SYNOPSIS

link.pl -h

link.pl <source-module-folder> <otrs-folder>

=head1 DESCRIPTION

This script installs a given OTRS module into the OTRS framework by creating
appropriate links.
Beware that code from the .sopm file is not executed.

Existing files are backupped by adding the extension '.old'.
So this script can be used for an already installed module, when linking
files from CVS checkout directory.

Please send any questions, suggestions & complaints to <ot@otrs.com>

=head1 TODO

When running the scripts twice, the '.old' files might be overwritten.

=cut

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use File::Spec    ();

# get options
my ($OptHelp);
GetOptions( 'h'   => \$OptHelp ) || pod2usage( -verbose => 1, message => 'invalid params' );

if ( $OptHelp ) {
    pod2usage( -verbose => 2 );   # this will exit the script
}

# Now get the work done

my $Source = shift || die "Need Application CVS location as ARG0";
$Source = File::Spec->rel2abs( $Source );
if (! -d $Source) {
    die "ERROR: invalid Application CVS directory '$Source'";
}

my $Dest = shift || die "Need Framework-Root location as ARG1";
$Dest = File::Spec->rel2abs( $Dest );
if (! -d $Dest) {
    die "ERROR: invalid Framework-Root directory '$Dest'";
}

my @Dirs;
my $Start = $Source;
R($Start);

sub R {
    my $In = shift;
    my @List = glob("$In/*");
    foreach my $File (@List) {
        $File =~ s/\/\//\//g;
        # recurse into subdirectories
        if (-d $File) {
            # skip CVS directories
            if ($File !~ /\/CVS$/) {
                R($File);
            }
        }
        else {
            my $OrigFile = $File;
            $File =~ s/$Start//;
            # check directory of location (in case create a directory)
            if ("$Dest/$File" =~ /^(.*)\/(.+?|)$/)
            {
                my $Directory = $1;
                my @Directories = split(/\//, $Directory);
                my $DirectoryCurrent = '';
                foreach my $Directory (@Directories) {
                    $DirectoryCurrent .= "/$Directory";
                    if ($DirectoryCurrent && ! -d $DirectoryCurrent) {
                        if (mkdir $DirectoryCurrent) {
                            print STDERR "NOTICE: Create Directory $DirectoryCurrent\n";
                        }
                        else {
                            die "ERROR: can't create directory $DirectoryCurrent: $!";
                        }
                    }
                }
            }
            if (-l "$Dest/$File") {
                unlink ("$Dest/$File") || die "ERROR: Can't unlink symlink: $Dest/$File";
            }
            if (-e "$Dest/$File") {
                if (rename("$Dest/$File", "$Dest/$File.old")) {
                    print "NOTICE: Backup orig file: $Dest/$File.old\n";
                }
                else {
                    die "ERROR: Can't rename $Dest/$File to $Dest/$File.old: $!";
                }
            }
            if (!-e $Dest) {
                die "ERROR: No such directory: $Dest";
            }
            elsif (!-e $OrigFile) {
                die "ERROR: No such orig file: $OrigFile";
            }
            elsif (!symlink ($OrigFile, "$Dest/$File")) {
                die "ERROR: Can't $File link: $!";
            }
            else {
                print "NOTICE: Link: $OrigFile -> \n";
                print "NOTICE:       $Dest/$File\n";
            }
        }
    }
}

