#!/usr/bin/perl

# Copyright 2013 Quentin Gibert.
# You may use this work without restrictions, as long as this notice is included.
# The work is provided "as is" without warranty of any kind, neither express nor implied.

use warnings;
use strict;
use Getopt::Std;
use MP3::Tag;
use File::Find ();
use File::Copy;

use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

our ( $opt_s,  $opt_d,  $opt_q,  $opt_v,  $opt_o );

getopts('s:d:ovq');
sub process;
sub wanted;
sub helpmsg;

if(!$opt_s or !$opt_d){
    helpmsg();
    exit 1;
}

# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, "$opt_s");
exit;


sub process {
  my ($file, $targetfile, $mp3, $artist, $album, $year, $title, $track, $comment,
  $genre, $albumdir, $initial);
    
    ($file) = @_;
    for(grep(/^.*\.(mp3|MP3)/, $file))
    {
	$mp3 = MP3::Tag->new($file);
	($title, $track, $artist, $album, $comment, $year, $genre) = $mp3->autoinfo();
	$albumdir = qq{$artist - $year - $album};
	$targetfile = qq{$track - $artist - $year - $album.mp3};
	( $initial ) = $artist =~ m/^(.)/;
	
	if(!$opt_q)
	{
	    print qq{Processing $file...\n};
	    print qq{Artist: "$artist" Year: "$year", Album: "$album", Title: "$title"\n};
	}
	if( !-d $opt_d )
	{
	    if($opt_v)
	    {
		print qq{Creating directory $opt_d\n};
	    }
	    mkdir($opt_d);
	}
	if( !-d qq{$opt_d/$initial})
	{
	    if($opt_v)
	    {
		print qq{Creating directory $opt_d/$initial\n};
	    }
	    mkdir(qq{$opt_d/$initial});
	}
	if( !-d qq{$opt_d/$initial/$artist} )
	{
	    if($opt_v)
	    {
		print qq{Creating directory: $opt_d/$initial/$artist\n};
	    }
	    mkdir(qq{$opt_d/$initial/$artist});
	}
	if( !-d qq{$opt_d/$initial/$artist/$albumdir} )
	{
	    if($opt_v)
	    {
		print qq{Creating directory: $opt_d/$initial/$artist/$albumdir\n};
	    }
	    mkdir(qq{$opt_d/$initial/$artist/$albumdir});
	}
	if( !-f qq{$opt_d/$initial/$artist/$albumdir/$targetfile} )
	{
	    copy($file, qq{$opt_d/$initial/$artist/$albumdir/$targetfile});
	}
	else
	{
	    if($opt_o)
	    {
		copy($file, qq{$opt_d/$initial/$artist/$albumdir/$targetfile});
	    }
	}
    }
}

sub wanted {
    my ($dev,$ino,$mode,$nlink,$uid,$gid);

    (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) &&
    process($name);
}

sub helpmsg(){
    no warnings;
    print qq{Usage:
 -s    <source_directory>
 -d    <destination_directory>
 -o    overwrite existing files
 -v    Verbose Mode.
 -q    Quiet Mode.};
}

__END__
