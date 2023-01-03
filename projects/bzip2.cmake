# bzip2
# xpbuild:cmake-scratch
xpProOption(bzip2 DBG)
set(VER 1.0.6)
set(REPO https://github.com/LuaDist/bzip2)
set(FORK https://github.com/smanders/bzip2)
set(PRO_BZIP2
  NAME bzip2
  WEB "bzip2" https://en.wikipedia.org/wiki/Bzip2 "bzip2 on wikipedia"
  LICENSE "open" https://spdx.org/licenses/bzip2-1.0.6.html "bzip2 BSD-style license"
  DESC "lossless block-sorting data compression library"
  REPO "repo" ${FORK} "forked bzip2 repo on github"
  GRAPH
  VER ${VER}
  GIT_ORIGIN ${FORK}
  GIT_UPSTREAM ${REPO}
  GIT_TAG xp${VER} # what to 'git checkout'
  GIT_REF v${VER} # create patch from this tag to 'git checkout'
  DLURL ${FORK}/archive/v${VER}.tar.gz
  DLMD5 768128c6df06b779256cf93149e0cae7
  DLNAME bzip2-v${VER}.tar.gz
  PATCH ${PATCH_DIR}/bzip2.patch
  DIFF ${FORK}/compare/
  DEPS_FUNC build_bzip2
  )
########################################
function(build_bzip2)
  if(NOT (XP_DEFAULT OR XP_PRO_BZIP2))
    return()
  endif()
  xpGetArgValue(${PRO_BZIP2} ARG NAME VALUE NAME)
  xpGetArgValue(${PRO_BZIP2} ARG VER VALUE VER)
  set(XP_CONFIGURE
    -DCMAKE_INSTALL_INCLUDEDIR=include/${NAME}_${VER}
    -DCMAKE_INSTALL_LIBDIR=lib
    -DXP_INSTALL_CMAKEDIR=share/cmake/tgt-${NAME}
    -DXP_NAMESPACE:STRING=xpro
    )
  set(TARGETS_FILE tgt-${NAME}/${NAME}-targets.cmake)
  string(TOUPPER ${NAME} PRJ)
  set(USE_VARS "set(${PRJ}_LIBRARIES xpro::bz2)\n")
  set(USE_VARS "${USE_VARS}list(APPEND reqVars ${PRJ}_LIBRARIES)\n")
  configure_file(${MODULES_DIR}/usexp.cmake.in
    ${STAGE_DIR}/share/cmake/usexp-${NAME}-config.cmake
    @ONLY NEWLINE_STYLE LF
    )
  xpCmakeBuild(${NAME} "" "${XP_CONFIGURE}" ${NAME}Targets)
  if(ARGN)
    set(${ARGN} "${${NAME}Targets}" PARENT_SCOPE)
  endif()
endfunction()
