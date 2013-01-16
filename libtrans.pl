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

my $libtrans = {
	# -- OndraRT
	ondrart => 'OndraRT.Core',
	ondrart_global => 'OndraRT.Global',
	ondrart_processlogger => 'OndraRT.Proclog',
	ondrart_ios => 'OndraRT.IOS',
	ondrart_kernel => 'OndraRT.Kernel',
	ondrart_heapcheck => 'OndraRT.Heapcheck',
	ondrart_log => 'OndraRT.Log',
	ondrart_log2 => 'OndraRT.Log2',
	ondrart_acl => 'OndraRT.ACL',
	ondrart_bos => 'OndraRT.BOS',
	ondrart_avbos => 'OndraRT.AVBOS',
	ondrart_iosbos => 'OndraRT.IOSBOS',
	ondrart_callback => 'OndraRT.OCallback',
	ondrart_datearith => 'OndraRT.Datearith',
	ondrart_dynreg => 'OndraRT.Dynreg',
	ondrart_getopt => 'OndraRT.Getopt',
	ondrart_charconv => 'OndraRT.Charconv',
	ondrart_minmax => 'OndraRT.MinMax',
	ondrart_minmaxqnx => 'OndraRT.MinMax.QNX',
	ondrart_minmaxsht => 'OndraRT.MinMax.Sht',
	ondrart_term => 'OndraRT.Terminal',
	ondrart_regex => 'OndraRT.Regex',
	ondrart_textreq => 'OndraRT.TextReq',
	ondrart_textfmt => 'OndraRT.TextFmt',
	ondrart_tint => 'OndraRT.TInt',
	ondrart_sig => 'OndraRT.Signal',
	ondrart_termcfg => 'OndraRT.TermCfg',
	ondrart_stdios => 'OndraRT.StdIOS',
	ondrart_typo => 'OndraRT.Typo',
	ondrart_help => 'OndraRT.Help',
	ondrart_bool => 'OndraRT.Bool',
	ondrart_hexdump => 'OndraRT.HexDump',
	# -- GSoap2
	gsoap2 => 'GSoap2.Lib',
	gsoap2noio => 'GSoap2.LibNoIO',
	'gsoap2++' => 'GSoap2.Lib++',
	'gsoap2++noio' => 'GSoap2.Lib++NoIO',
	gsoap2env => 'GSoap2.Env',
	'gsoap2++env' => 'GSoap2.Env++',
	avsoapclient => 'AVSoapClient.Lib',
	# -- Fbar2
	fbar2 => 'Fbar2.Lib',
	fbar2repl => 'Fbar2.Repl',
	fbar2utils => 'Fbar2.Utils',
	fbar2stateutils => 'Fbar2.StateUtils',
	# -- Kernel
	jadro => 'Jadro.Lib',
	jadro_killer => 'Jadro.Killer',
	# -- Datstr
	datstr => 'Datstr.Lib',
	# -- Backup server support
	backsrvsupp => 'BacksrvSupp.Lib',
	# -- Jirka's utils library
	utils => 'Utils.Lib',
	# -- Shared timers
	otimer => 'OTimer.Lib',
	otimermgr => 'OTimerMgr.Lib',
	otimerextcli => 'OTimerExtCli.Lib',
	# -- Currently not supported libraries
#	prostredi => ('Prostredi.Lib', 'Cas.Lib', 'Konfig.Lib', )'Sys.prostredi',
	jzshr => 'Sys.jzshr',
	shutils => 'Sys.shutils',
	sro => 'Sys.sro',
	medialib => 'Sys.medialib',
	remsez => 'Sys.remsez',
	ovl => 'Sys.ovl',
	konfig => 'Sys.konfig',
	odynvars => 'Sys.odynvars',
	sys => 'Sys.sys',
	licastra => 'Sys.licastra',
	uint_64 => 'Sys.uint_64',
	avtimespec => 'Sys.avtimespec',
	stl => 'Sys.stl',
	bloblib => 'Sys.bloblib',
	llenvlib => 'Sys.llenvlib',
	axml => 'Sys.axml',
	'libparsifal-1.1.0' => 'Sys.libparsifal-1.1.0',
	'libexpat-2.0.1' => 'Sys.libexpat-2.0.1'
};

$libtrans;
