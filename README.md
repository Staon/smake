smake
=====

SMake is a build tool mainly for C/C++. The key features are:

1. platform independent declarative description of projects,
2. resolving of inter project dependencies,
3. support of VCS workflows.

The SMake can be compared with the Maven or SCons tools. But it
implements several own ideas.

The SMake is succesfully using internaly in our company
[Aveco s.r.o.](http://www.aveco.com/). However, the project
is not usable in another environment. The goal is to rewrite
it to support other platforms (operating systems and compilers)
and to be configurable and extendable.
