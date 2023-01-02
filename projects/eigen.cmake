# eigen
# xpbuild:cmake-patch
xpProOption(eigen)
set(VER 3.3.7)
set(REPO https://gitlab.com/libeigen/eigen)
set(FORK github.com/smanders/eigen)
set(PRO_EIGEN
  NAME eigen
  WEB "Eigen" http://eigen.tuxfamily.org/ "Eigen website"
  LICENSE "open" "http://eigen.tuxfamily.org/index.php?title=Main_Page#License" "Eigen license: MPL2 (aka Mozilla Public License)"
  DESC "C++ template library for linear algebra [cmake-patch]"
  REPO "repo" ${REPO} "eigen repo on gitlab"
  GRAPH
  VER ${VER}
  GIT_UPSTREAM ${REPO}.git
  GIT_ORIGIN https://${FORK}.git
  GIT_TAG xp${VER} # what to 'git checkout'
  GIT_REF ${VER} # create patch from this tag to 'git checkout'
  DLURL ${REPO}/-/archive/${VER}/eigen-${VER}.tar.bz2
  DLMD5 b9e98a200d2455f06db9c661c5610496
  PATCH ${PATCH_DIR}/eigen.patch
  DIFF https://${FORK}/compare/
  DEPS_FUNC build_eigen
  DEPS_VARS EIGEN_INCDIR
  )
########################################
function(build_eigen)
  if(NOT (XP_DEFAULT OR XP_PRO_EIGEN))
    return()
  endif()
  xpGetArgValue(${PRO_EIGEN} ARG NAME VALUE NAME)
  xpGetArgValue(${PRO_EIGEN} ARG VER VALUE VER)
  set(incDir include/${NAME}_${VER})
  set(XP_CONFIGURE
    -DCMAKE_INSTALL_INCLUDEDIR=${incDir}
    -DXP_INSTALL_CMAKEDIR=share/cmake/tgt-${NAME}
    -DEIGEN_BUILD_PKGCONFIG:BOOL=OFF
    )
  set(TARGETS_FILE tgt-${NAME}/Eigen3Targets.cmake)
  string(TOUPPER ${NAME} PRJ)
  set(USE_VARS "set(${PRJ}_LIBRARIES Eigen3::${NAME})\n")
  set(USE_VARS "${USE_VARS}list(APPEND reqVars ${PRJ}_LIBRARIES)\n")
  configure_file(${MODULES_DIR}/usexp.cmake.in
    ${STAGE_DIR}/share/cmake/usexp-${NAME}-config.cmake
    @ONLY NEWLINE_STYLE LF
    )
  set(BUILD_CONFIGS Release) # this project is only copying headers
  xpCmakeBuild(${NAME} "" "${XP_CONFIGURE}" ${NAME}Targets)
  if(ARGN)
    set(${ARGN} "${${NAME}Targets}" PARENT_SCOPE)
    set(EIGEN_INCDIR ${incDir}/eigen3 PARENT_SCOPE)
  endif()
endfunction()
