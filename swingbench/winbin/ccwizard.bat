@echo OFF
set Args=%1 %2 %3 %4 %5 %6 %7 %8 %9
for /L %%i in (0,1,8) do @shift
set Args=%Args% %1 %2 %3 %4 %5 %6 %7 %8 %9
java -cp ../launcher LauncherBootstrap -executablename ccwizard ccwizard -c ../wizardconfigs/ccwizard.xml %Args%
