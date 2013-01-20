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

#  Install a directory with catalogues of messages
package SMakeParser::TdbDirTask;

use SBuild::Task;

@ISA = qw(SBuild::Task);

#  Ctor
#
#  Usage: newTask($name, $resource, $dirres)
sub newTask {
	my $class = $_[0];
	my $this = SBuild::Task->newTask($_[1], $_[2]);
	$this->{dirres} = $_[3];
	bless $this, $class;
}

#  Run the task
#
#   Usage: processTask(profile, reporter, $project)
#   Return: False when the task fails
sub processTask {
	my $this = $_[0];
	my $profile = $_[1];
	my $reporter = $_[2];
	my $project = $_[3];

	my $dirres = $this->{dirres};
	my $installer = $profile->getFileInstaller;

	# -- find all language variants
	my $dir = $dirres->getFullDirectory($profile);
	my $retval = 1;
	if(opendir(DIR, $dir)) {
		my @subdirs = grep { /^[^.]/ && -d File::Spec->catdir($dir, $_) } readdir(DIR);
		foreach my $subdir (@subdirs) {
			my $langdir = File::Spec->catdir($dir, $subdir);
			my $tgdir = File::Spec->catdir("tdb", $subdir);
			# -- find all catalogue files
			if(opendir(LANG, $langdir)) {
				my @catfiles = grep { /[.]tdb$/ && -f File::Spec->catdir($langdir, $_) } readdir(LANG);
				foreach my $catfile (@catfiles) {
					my $srcfile = File::Spec->catfile($langdir, $catfile);
					if(! $installer->installFile($reporter, $project, $srcfile, $tgdir)) {
						$retval = 0;
					}
				}
				closedir(LANG);
			}
		}
		closedir DIR;
	}

	return $retval;
}

return 1;
