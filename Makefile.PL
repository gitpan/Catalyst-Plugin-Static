use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Plugin::Static',
    AUTHOR    => 'Sebastian Riedel (sri@oook.de)',
    PREREQ_PM => {
        Catalyst     => '2.99',
        File::MMagic => 0,
        File::Slurp  => 0
    },
    VERSION_FROM => 'Static.pm'
);