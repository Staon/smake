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

use SBuild::TopOrder;
use SBuild::TopOrder::Node;
use PTest;

# Create a node and check userdata
$node = SBuild::TopOrder::Node->newNode("Ahoj");
TEST_REPORT(__FILE__, __LINE__) 
	if ! ($node->getUserData eq "Ahoj");

# Dependencies in the node
$node->addDependency("Nazdar");
$node->addDependency("Pokus");
my @list = @{$node->getDependencyList()};
PTest::TEST_REPORT(__FILE__, __LINE__)
	if $list[0] ne "Nazdar" or $list[1] ne "Pokus";

# Topological order (without a cycle)
$order = SBuild::TopOrder->newTopOrder;
$order->addNode("NodeA", "NodeA");
$order->addNode("NodeB", "NodeB");
$order->addNode("NodeC", "NodeC");
$order->addNode("NodeD", "NodeD");
$order->addNode("NodeE", "NodeE");
$order->addDependency("NodeA", "NodeB");
$order->addDependency("NodeA", "NodeC");
$order->addDependency("NodeA", "NodeE");
$order->addDependency("NodeB", "NodeC");
$order->addDependency("NodeB", "NodeD");
$order->addDependency("NodeB", "NodeE");
$order->addDependency("NodeC", "NodeD");
$order->addDependency("NodeE", "NodeC");
$order->addDependency("NodeE", "NodeD");
($ret, @sorted) = $order->computeOrder();
PTest::TEST_REPORT(__FILE__, __LINE__)
	if ! $ret or
	   $sorted[0] ne "NodeA" or
	   $sorted[1] ne "NodeB" or
	   $sorted[2] ne "NodeE" or
	   $sorted[3] ne "NodeC" or
	   $sorted[4] ne "NodeD";

# Topological order (with a cycle)
$order->addDependency("NodeD", "NodeE");
($ret, @cycled) = $order->computeOrder();
PTest::TEST_REPORT(__FILE__, __LINE__)
	if $ret || ! PTest::checkLists(\@cycled, ["NodeC", "NodeD", "NodeE"]);

print "Test passed\n";
