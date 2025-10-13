use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'BHSets',
    VERSION_FROM      => 'lib/BHSets.pm',
    PREREQ_PM         => {},
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/BHSets.pm',
       AUTHOR         => 'Edgar Gonzàlez i Pellicer <egonzalez@lsi.upc.edu>') :
      ()),
    LIBS              => [''],
    INC               => '-I.',
    OBJECT            => '$(O_FILES)',
    CC                => 'g++',
    LD                => '$(CC)',
    XSOPT             => '-C++',
);
