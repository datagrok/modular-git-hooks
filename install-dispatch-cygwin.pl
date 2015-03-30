#!/usr/bin/perl
use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename;
use File::Copy;

# Locate hooks
my $hooks_dir;
if(chomp(my $git_dir = `git rev-parse --git-dir`)){
	$hooks_dir = "$git_dir/hooks";
	mkdir $hooks_dir unless -d $hooks_dir;
} else {
	print <<TEXT;
Warning: we don't seem to be within a git repository. Assuming current
directory is where you want to set up 'dispatch'. (For use as a shared
hooks directory that you'll attach to git repositories with symlinks.)
TEXT
	$hooks_dir = '.';
}

# Locate dispatch
my $dispatch_abs = abs_path(dirname($0).'/dispatch');
unless( -e $dispatch_abs ){
	print "Error: could not find dispatch at expected location, $dispatch_abs.";
	exit 2;
}
my $hooks_abs = abs_path($hooks_dir);

# If 'dispatch' lives somewhere within $git_dir/hooks, 
# we must relative-link to it. 
# Otherwise, absolute path
my ($dispatch) = ($dispatch_abs=~m@^$hooks_abs/(.+)$@);
$dispatch = $dispatch_abs unless defined $dispatch;

# Create hooks
foreach my $hook (qw(applypatch-msg commit-msg post-applypatch post-checkout post-commit post-merge post-receive post-rewrite post-update pre-applypatch pre-auto-gc pre-commit pre-push pre-rebase pre-receive prepare-commit-msg update)){
	unless( -d "$hooks_dir/$hook.d" ){
		print "create $hook.d\n";
		mkdir "$hooks_dir/$hook.d";
	} else {
		print "skip   $hook.d (exists)\n"; 
	}

	my $hook_fn = "$hooks_dir/$hook";
	if( -e $hook_fn ){
		if(open(HOOK, $hook_fn) && grep {/export GIT_HOOK_TYPE/} <HOOK>){
			close(HOOK);
			# Update our existing hook script to dispatch
			print "delete $hook (updating hook)\n";
			`rm "$hook_fn"`;
		} else {
			# move it into our hooks directory.
			my $uid = 0;
			my $new_hook = "$hook.orig";
			while ( -e "$hooks_dir/$hook.d/$new_hook" ){
				$new_hook = "$hook.".++$uid.".orig";
			}
			print "move   $hook -> $hook.d/$new_hook\n";
			move($hook_fn, "$hooks_dir/$hook.d/$new_hook");
		}
	}
	
	# cygwin symlinks lose the path when using basename $0
	# `ln -s "$dispatch" "$hook_fn"`;
	# so instead create a script which sets an environment variable
	unless( -e $hook_fn ){
		if(open(HOOK, ">$hook_fn")){
			print "link   $hook -> dispatch\n";
			print HOOK <<CODE;
#!/bin/sh
export GIT_HOOK_TYPE=$hook
echo \$@ | $dispatch
CODE
			close HOOK;
			chmod 0775, $hook_fn;
		} else {
			print "creating new hook failed\n";
		}
	} else {
		print "hook already exists\n";
	}
}

