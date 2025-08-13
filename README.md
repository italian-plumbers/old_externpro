# externpro

[![GitHub license](https://img.shields.io/github/license/italian-plumbers/old_externpro.svg)](https://github.com/italian-plumbers/old_externpro) [![GitHub release](https://img.shields.io/github/release/italian-plumbers/old_externpro.svg)](https://github.com/italian-plumbers/old_externpro)

an extensible project to build (or copy pre-built) external (3rd-party) [projects](projects/README.md)

## description

externpro supports options for [4 steps](https://github.com/italian-plumbers/old_externpro/blob/15.10.2/modules/macpro.cmake#L67-L72): mkpatch (make patch), download, patch, build -- with patch being the default option

externpro makes heavy use of cmake's [ExternalProject](http://www.kitware.com/media/html/BuildingExternalProjectsWithCMake2.8.html) module

### mkpatch

for each project in the [projects directory](projects) the mkpatch step: clones a repository (if `GIT_ORIGIN` is defined), does a checkout of a specified branch or hash (specified with `GIT_TAG`), and creates a patch (the diff between `GIT_REF` and `GIT_TAG`) -- this is how the [patches directory](patches) is populated and updated

this is typically a task done by a single maintainer - others developers who wish to use externpro aren't usually doing this step

### download

for each project in the [projects directory](projects) which implements a download_*project-name*() cmake function or defines `DLURL` and `DLMD5`, the download step: downloads and/or verifies the md5 of a compressed archive of a specified URL -- this is how the **_bldpkgs directory** is populated and updated

executing this step produces a directory structure suitable for light transport - burn to media to take into a closed environment or disconnect from the internet and you'll still be able to execute the next steps

### patch

for each project in the [projects directory](projects) which implements a patch_*project-name*() cmake function or has a compressed archive or a patch, the patch step: downloads the compressed archive (if it hasn't already been downloaded), verfies the md5, expands the compressed archive, and applies the patch (made by mkpatch, if one exists)

executing this step produces the source code in a patched state, suitable for debugging and stepping into the source

if a developer already has externpro installed (using the installer produced by the build step below), they can simply run the patch step (on an externpro revision that matches their installed revision) and are now able to debug and step into third party code

### build

for each project in the [projects directory](projects) which implements a build_*project-name*() cmake function, the build step: executes the patch step then builds the project with the compiler (aka cmake generator) detected or specified at cmake-time of externpro

externpro also contains cmake options to specify different build platforms (32, 64 bit) and configurations (release, debug, multiple release runtime support with MSVC) - all of these platforms and configurations are built at build-time of externpro

the `package` target of externpro will build an installer suitable for the OS on which you're building

## advantages

* compiler choice and compatibility - build third-party projects with the same compiler you're using with your project
* version choice - choose the exact version of a third-party project you want to employ in your project (can be bleeding edge or trailing what's available via other means)
* patch - apply fixes or tweaks you've found to be necessary or easily cherry-pick a fix from a version you're not ready to move to yet
* consistency across platforms - every OS can be using the same (perhaps patched) version of third-party code
* platform choice - build for the OS and architecture you support
* build configuration choice - support debug builds for stepping into code (and gaining understanding) and release configurations that utilize different runtimes (DLL or static)
* compiler flags - consistency across all third-party libraries and your project(s) is often required (c++11, fpic, libumem on Solaris)

## usage

to build and use externpro from another project you can either create a *build version* of externpro or an *installed version*

a build version is created by simply building externpro and an installed version involves building, making the package (aka installer), and installing

one difference between a build version and an installed version is where the find script looks to find externpro - you can see the PATHS searched, in order, in the [find script](https://github.com/italian-plumbers/old_externpro/blob/20.10.1/modules/Findscript.cmake.in#L80-L88)

if you always plan to use an installed version the path to the source and build directories doesn't matter -- only the path where it is installed matters, unless you use an environment variable (examine the find script for suitable install locations)

unless you have a reason to use an old release (`git checkout <tag>`) or have a reason to use a development version (`git checkout -b dev origin/dev` -- where development == not ready for release), you should be using the master branch (which is always the latest release)

```bash
git clone https://github.com/italian-plumbers/old_externpro
cd externpro
git submodule init
git submodule update
cmake --workflow --preset=[Linux|Windows]
```
