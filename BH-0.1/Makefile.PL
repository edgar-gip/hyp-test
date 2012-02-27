use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'BH',
    VERSION_FROM      => 'lib/BH.pm',
    PREREQ_PM         => {},
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/BH.pm',
       AUTHOR         =>
       [ 'Ignasi Abío i Roig <iabio@lsi.upc.edu>',
	 'Edgar Gonzàlez i Pellicer <egonzalez@lsi.upc.edu>' ]) :
      ()),
    LIBS              => [''],
    INC               => '-I.',
    OBJECT            => '$(O_FILES)',
    CC                => 'g++',
    LD                => '$(CC)',
    XSOPT             => '-C++',
);
