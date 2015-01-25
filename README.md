LICENSE
=======
All scripts here are released uder the BSD 2-Clause open license (http://opensource.org/licenses/BSD-2-Clause).
It basically says that you can do whatever you like with the code as long as you credit the author and provide the license with it.
Also see LICENSE in the repo.

Support
=======
I do not promise any support for any of the provided scripts. That said, I'll do what I can for you if I'm not too busy and/or drunk.

General information
===================
The paths are all configurable of course.
The help information that the scripts give is dynamic and is provided here only for reference.

Scripts
=======

chameleon
---------
A background changer

	$ chameleon --help
	Usage: chameleon [options] <target>
	Options:
		-m|--bg-manager			# Specify a bg manager to use. The default is feh.
		-M|--bg-mode			# Specify the bg mode.
		-C|--color				# Specify a color for the background. If used without a target image, fills the background with the color. Needs imagemagick for that though.
		-d|--daemon				# Daemon mode: sets the background periodically. Useful if the taget is a dir.
		-D|--daemon-delay		# Delay for periodic bg changing, in seconds (default: 900).
		-r|--recursive			# If the target is a dir, search for files recursively.
		-v|--verbose			# Be verbose.
		-h|--help				# Show this message.
	Modes:
		feh: center, fill, max, scale, tile.

miner
-----
Miner is a simple tool to merge (patch) zip archives.

	$ miner
	Usage: miner <zip0> <zip1>

ixio
----
A client for ix.io. I didn't like the official one.  
Depends on curl.

	$ cmd | ixio
	or
	$ ixio < file

	$ ixio -h
	Usage: ixio [flags] < <file>
    Flags:
        -h|--help            Show this message
        -d|--delete <id>     Delete an id
        -p|--put <id>        Overwrite an id
        -l|--limit <num>     Number of times th paste can be read before it's deleted.

sprunge
-------
A script for sprunge, because I'm weird and hate aliases.  
Depends on curl.

	$ cmd | sprunge
	or
	$ sprunge < file

imgur
-----
imgur is a relatively simple imgur client. It does not support authorization.

	Usage: imgur [flags] [file]
	Flags:
		-h    Show this message.
		-s    Make a screenshot and upload that. If a file is specified, the screenshot is saved there.
		-F    Make a fullscreen screenshot instead of asking you to select a window or an area. Implies -s.
		-R    Remove the file after uploading.
		-c    Source an alternative config file.

	You can set some stuff in a config file. Look in the argument handling part of the script for details.
	The default path is $HOME/.config/imgur.rc.sh
