use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'XFig',
    VERSION_FROM => 'lib/XFig.pm',
    PREREQ_PM    => {},
    AUTHOR       => 'Edgar Gonzàlez <egonzalez@lsi.upc.edu>',
    LIBS         => ['-lX11'],
    DEFINE       => '',
    INC          => '-I.',
    OBJECT       => '$(O_FILES)',
);
