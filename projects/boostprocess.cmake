# boost process
set(VER 1.76.0)
set(REPO https://github.com/boostorg/process)
set(FORK https://github.com/italian-plumbers/process)
set(PRO_BOOSTPROCESS
  NAME boostprocess
  SUPERPRO boost
  SUBDIR . # since the patch is all headers, apply to root of boost, not libs/process
  WEB "process" http://boost.org/libs/process "boost process website"
  DESC "zero-overhead dimensional analysis and unit/quantity manipulation and conversion"
  REPO "repo" ${REPO} "process repo on github"
  VER ${VER}
  GIT_ORIGIN ${FORK}
  GIT_UPSTREAM ${REPO}
  GIT_TRACKING_BRANCH develop
  GIT_TAG xp${VER}
  GIT_REF boost-${VER}
  PATCH ${PATCH_DIR}/boost.process.patch
  PATCH_STRIP 2 # Strip NUM leading components from file names (defaults to 1)
  DIFF ${FORK}/compare/boostorg:
  )
