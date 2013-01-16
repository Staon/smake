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

#  SOAP server created from a WSDL specification
package SMakeParser::WsdlServerRecord;

use SMakeParser::WsdlRecord;

@ISA = qw(SMakeParser::WsdlRecord);

#  Ctor
#
#  Usage: newRecord($mask, $prefix, $srvname, \@extrasrv)
sub newRecord {
	my $class = $_[0];
	my $this = SMakeParser::WsdlRecord->newRecord(
	                  $_[1], $_[2], $_[3], 1, $_[4]);
	bless $this, $class;
}

#  Ctor - with sed operation
#
#  Usage: newRecordSed($mask, $prefix, $srvname, \@extrasrv, $sedfile, $hdrfile)
sub newRecordSed {
	my $class = $_[0];
	my $this = SMakeParser::WsdlRecord->newRecordSed(
	                  $_[1], $_[2], $_[3], 1, $_[4], $_[5], $_[6]);
	bless $this, $class;
}

return 1;
