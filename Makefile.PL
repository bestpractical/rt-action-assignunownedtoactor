use inc::Module::Install;


RTx 'RT-Action-AssignUnownedToActor';
all_from 'lib/RT/Action/AssignUnownedToActor.pm';
readme_from 'lib/RT/Action/AssignUnownedToActor.pm';
license  'gplv2';

requires_rt('3.8.0');

sign;
WriteAll;
