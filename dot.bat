@echo off
cd %~dp0

del %USERPROFILE%\.gitconfig
mklink /H %USERPROFILE%\.gitconfig USERPROFILE\.gitconfig
del %USERPROFILE%\.npmrc
mklink /H %USERPROFILE%\.npmrc USERPROFILE\.npmrc
del %USERPROFILE%\.yarnrc
mklink /H %USERPROFILE%\.yarnrc USERPROFILE\.yarnrc
