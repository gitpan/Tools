### write the Makefile ###
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME			=> 'Tools',

	PREREQ_PM   => {
		'Test::More'    => 0,
	},
);