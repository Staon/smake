# Copyright (C) 2013 Aveco s.r.o.
#
# This file is part of SMake.
#
# SMake is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SMake is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SMake.  If not, see <http://www.gnu.org/licenses/>.

#  Cache of project objects
package SBuild::ProjectCache;

use File::Path qw(mkpath rmtree);
use File::Spec;
use Data::Dumper;

#  Ctor
#
#  Usage: newCache($max_items, $cache_directory)
sub newCache {
	my $class = $_[0];
	my $max_items = $_[1];
	my $path = File::Spec->catdir($_[2], $$);
	my $this = [
		[],    # R-bits
		[],    # keys
		[],    # values
		{},    # asociative access
		$max_items,
		$path,
		0      # the hand
	];
	
	# -- initialize the buckets
	for(my $i = 0; $i < $max_items; ++ $i) {
		$this->[0]->[$i] = undef;
		$this->[1]->[$i] = undef;
		$this->[2]->[$i] = undef;
	}
	
	# -- prepare cache directory
	rmtree($path);
	mkpath($path);
	
	bless $this, $class;
}

#  Dtor
sub DESTROY {
	my $this = $_[0];
	rmtree($this->[5]);
}

sub find_bucket_for_write {
	my $this = $_[0];
	my $hand = $this->[6];
	my $max = $this->[4];
	
	# -- find the bucket
	while($this->[0]->[$hand]) {
		$this->[0]->[$hand] = undef;
		$hand = ($hand + 1) % $max;
	}
	
	$this->[6] = $hand;   # -- store new hand
	return $hand;
}

sub kick_an_object {
	my ($this, $index) = @_;
	# -- when the bucket contains a value, store it into a file
	my $vkey = $this->[1]->[$index];
	if(defined($vkey)) {
#		print "Kick an object $vkey\n";
		# -- serialize the data
		my $vvalue = $this->[2]->[$index];
		my $purity = $Data::Dumper::Purity;
		my $indent = $Data::Dumper::Indent;
		$Data::Dumper::Purity = 1;
		$Data::Dumper::Indent = 0;
		my $slurp = Data::Dumper->Dump([$vvalue], ["object"]);
		$Data::Dumper::Purity = $purity;
		$Data::Dumper::Indent = $indent;
		
		# -- create filename
		my $filename = File::Spec->catfile($this->[5], $vkey . ".cache");

		# -- save the file
		local *FILE;
		open(FILE, ">$filename");
		print FILE $slurp;
		close(FILE);

		# -- remove the object from memory
		$this->[0]->[$index] = undef;
		$this->[1]->[$index] = undef;
		$this->[2]->[$index] = undef;
		delete $this->[3]->{$vkey};
	}
}

#  Put an object into the cache. When the maximum size is reached,
#  some stored object is dumped into the disk.
#
#  Usage: putObject($key, $object)
sub putObject {
	my ($this, $key, $object) = @_;
	
	my $asoc = $this->[3];
	if(exists($asoc->{$key})) {
		# -- overwrite stored value
		my $index = $asoc->{$key};
		$this->[0]->[$index] = 1;
		$this->[2]->[$index] = $object;
	}
	else {
		# -- store the value into the cache
		my $index = $this->find_bucket_for_write();
		$this->kick_an_object($index);
		# -- store new value
		$this->[0]->[$index] = 1;
		$this->[1]->[$index] = $key;
		$this->[2]->[$index] = $object;
		$this->[3]->{$key} = $index;
	}
}

#  Get an object
#
#  Usage: getObject($key)
#  Return: The object of undef, when the object doesn't exist
sub getObject {
	my ($this, $key) = @_;

	# -- check whether the object is stored in memory
	my $asoc = $this->[3];
	if(exists($asoc->{$key})) {
		my $index = $asoc->{$key};
		$this->[0]->[$index] = 1;    # -- set the R-bit
		return $this->[2]->[$index];
	}
	
	# -- the object ins't in the memory cache. See into the file storage
	my $filename = File::Spec->catfile($this->[5], $key . ".cache");
	return undef if(! -r $filename);
	
	# -- read the object
	local (*FILE);
	open(FILE, "<$filename");
	my @data = <FILE>;
	close(FILE);
	my $data = join("", @data);

	# -- unserialize the object
	my $object;
	eval $data;
	die $@ if $@ || ! defined($object);
	
	# -- store read object
	my $index = $this->find_bucket_for_write();
	$this->kick_an_object($index);
	$this->[0]->[$index] = 1;
	$this->[1]->[$index] = $key;
	$this->[2]->[$index] = $object;
	$this->[3]->{$key} = $index;
	
	return $object;
}

return 1;
