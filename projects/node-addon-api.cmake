# node-addon-api
# xpbuild:cmake-scratch
xpProOption(node-addon-api)
set(VER 3.0.2)
set(REPO https://github.com/nodejs/node-addon-api)
set(FORK https://github.com/italian-plummers/node-addon-api)
set(PRO_NODE-ADDON-API
  NAME node-addon-api
  WEB "node-addon-api" ${REPO} "node-addon-api on github"
  LICENSE "open" ${REPO}/blob/${VER}/LICENSE.md "The MIT License - http://opensource.org/licenses/mit-license.php"
  DESC "Module for using N-API from C++"
  REPO "repo" ${REPO} "node-addon-api repo on github"
  GRAPH BUILD_DEPS nodejs
  VER ${VER}
  GIT_ORIGIN ${FORK}
  GIT_UPSTREAM ${REPO}
  GIT_TRACKING_BRANCH main
  GIT_TAG xp${VER} # what to 'git checkout'
  GIT_REF ${VER} # create patch from this tag to 'git checkout'
  DLURL ${REPO}/archive/${VER}.tar.gz
  DLMD5 020c40cbb9af791f7934fa66f87c904c
  DLNAME node-addon-api-${VER}.tar.gz
  PATCH ${PATCH_DIR}/node-addon-api.patch
  DIFF ${FORK}/compare/nodejs:
  )
########################################
function(build_node_addon_api)
  if(NOT (XP_DEFAULT OR XP_PRO_NODE-ADDON-API))
    return()
  endif()
  xpBuildDeps(depTgts ${PRO_NODE-ADDON-API})
  xpGetArgValue(${PRO_NODE-ADDON-API} ARG NAME VALUE NAME)
  xpGetArgValue(${PRO_NODE-ADDON-API} ARG VER VALUE VER)
  set(XP_CONFIGURE
    -DCMAKE_INSTALL_INCLUDEDIR=include/${NAME}_${VER}
    -DXP_INSTALL_CMAKEDIR=share/cmake/tgt-${NAME}
    -DXP_MODULE_PATH=${CMAKE_DIR}
    -DXP_NAMESPACE:STRING=xpro
    )
  set(FIND_DEPS "xpFindPkg(PKGS node)\n")
  set(TARGETS_FILE tgt-${NAME}/${NAME}-targets.cmake)
  string(TOUPPER ${NAME} PRJ)
  set(USE_VARS "set(${PRJ}_LIBRARIES xpro::${NAME})\n")
  set(USE_VARS "${USE_VARS}list(APPEND reqVars ${PRJ}_LIBRARIES)\n")
  configure_file(${MODULES_DIR}/usexp.cmake.in
    ${STAGE_DIR}/share/cmake/usexp-${NAME}-config.cmake
    @ONLY NEWLINE_STYLE LF
    )
  set(BUILD_CONFIGS Release) # this project is only copying headers
  xpCmakeBuild(${NAME} "${depTgts}" "${XP_CONFIGURE}")
endfunction()
