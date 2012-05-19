use inc::Module::Install;
use Module::Install::AutoInstall;
use strict; use warnings;

# Define metadata
name           'TimerServer';
all_from       'lib/TimerServer.pm';

# Specific dependencies
requires       'Dancer' => '1.3095',
requires       'Dancer::Plugin::REST' => '0.07';
requires       'Dancer::Plugin::DBIC' => '0.1506';
requires       'DBD::SQLite' => '1.35',
test_requires  'Test::More'  => '0.98';
test_requires  'DBIx::Class';
test_requires  'DBIx::Class::EncodedColumn' => '0.00011';
test_requires  'DBIx::Class::TimeStamp' => '0.14';
test_requires  'Template' => '2.24';

auto_install();
WriteAll;
