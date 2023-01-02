# jpegxp
# xpbuild:cmake-scratch
# http://packages.debian.org/sid/libjpeg-dev
# http://libjpeg6b.sourcearchive.com/
# http://libjpeg8.sourcearchive.com/
xpProOption(jpegxp DBG)
set(VER 22.04) # latest jxp branch commit date (yr.mo)
set(REPO github.com/smanders/jpegxp)
set(PRO_JPEGXP
  NAME jpegxp
  WEB "jpegxp" http://www.ijg.org/ "Independent JPEG Group website"
  LICENSE "open" https://github.com/smanders/libjpeg/blob/upstream/README "libjpeg: see LEGAL ISSUES, in README (no specific license mentioned)"
  DESC "JPEG codec with mods for Lossless, 12-bit lossy (XP)"
  REPO "repo" https://${REPO} "jpegxp repo on github"
  VER ${VER}
  GIT_ORIGIN https://${REPO}.git
  GIT_TAG jxp # what to 'git checkout'
  GIT_REF jxp.220421 # create patch from this tag to 'git checkout'
  PATCH ${PATCH_DIR}/jpegxp.patch
  DIFF https://${REPO}/compare/
  SUBPRO jpeglossy8 jpeglossy12 jpeglossless
  )
########################################
function(build_jpegxp)
  if(NOT (XP_DEFAULT OR XP_PRO_JPEGXP))
    return()
  endif()
  xpGetArgValue(${PRO_JPEGXP} ARG NAME VALUE NAME)
  xpGetArgValue(${PRO_JPEGXP} ARG VER VALUE VER)
  set(XP_CONFIGURE
    -DCMAKE_INSTALL_INCLUDEDIR=include/${NAME}_${VER}
    -DCMAKE_INSTALL_LIBDIR=lib
    -DXP_INSTALL_CMAKEDIR=share/cmake/tgt-${NAME}
    -DXP_NAMESPACE:STRING=xpro
    )
  set(TARGETS_FILE tgt-${NAME}/${NAME}-targets.cmake)
  string(TOUPPER ${NAME} PRJ)
  set(USE_VARS "set(${PRJ}_LIBRARIES xpro::${NAME})\n")
  set(USE_VARS "${USE_VARS}list(APPEND reqVars ${PRJ}_LIBRARIES)\n")
  configure_file(${MODULES_DIR}/usexp.cmake.in
    ${STAGE_DIR}/share/cmake/usexp-${NAME}-config.cmake
    @ONLY NEWLINE_STYLE LF
    )
  xpGetArgValue(${PRO_JPEGXP} ARG SUBPRO VALUES subs)
  foreach(sub ${subs})
    list(APPEND XP_DEPS ${NAME}_${sub})
  endforeach()
  xpCmakeBuild(${NAME} "${XP_DEPS}" "${XP_CONFIGURE}")
endfunction()
