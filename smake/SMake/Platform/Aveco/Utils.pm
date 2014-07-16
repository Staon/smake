# Copyright (C) 2014 Aveco s.r.o.
#
# This file is part of SMake.
#
# SMake is a free software: you can redistribute it and/or modify
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

package SMake::Platform::Aveco::Utils;

#  Convert specification of size ([[:digit:]]+(k|m)?) to a raw number
#
#  Usage: getSizeNumber($string)
sub getSizeNumber {
  my ($string) = @_;
  if($string =~ /^([0-9]+)(k|m)?$/) {
    my $number = $1;
    my $suffix = $2;
    $suffix = "" if(!defined($suffix));
    $number = $number * 1024 if($suffix eq "k");
    $number = $number * 1024 * 1024 if($suffix eq "m");
    return $number;
  }
  else {
      die "Invalid size specification '$string'.";
  }
}

#  Round a number to a multiple of a value
#
#  Usage: roundToMultiple($number, $mult)
sub roundToMultiple {
  my ($number, $mult) = @_;
  my $n = $number + ($mult - 1);
  return $n - ($n % $mult);
}

return 1;
