# nodejs
# xpbuild:gyp
set(VER 14.17.6)
xpProOption(nodejs)
set(REPO https://github.com/nodejs/node)
set(FORK https://github.com/italian-plumbers/node)
set(PRO_NODEJS
  NAME nodejs
  WEB "Node.js" http://nodejs.org "Node.js website"
  LICENSE "open" https://raw.githubusercontent.com/nodejs/node/v${VER}/LICENSE "MIT license"
  DESC "platform to build scalable network applications"
  REPO "repo" ${REPO} "node repo on github"
  GRAPH GRAPH_NODE nodejs BUILD_DEPS nasm
  VER ${VER}
  GIT_ORIGIN ${FORK}
  GIT_UPSTREAM ${REPO}
  GIT_TRACKING_BRANCH main
  GIT_TAG xp${VER} # what to 'git checkout'
  GIT_REF v${VER} # create patch from this tag to 'git checkout'
  PATCH ${PATCH_DIR}/nodejs.patch
  DIFF ${FORK}/compare/nodejs:
  DLURL http://nodejs.org/dist/v${VER}/node-v${VER}.tar.gz
  DLMD5 d1f71584169c9d293e5264e1966c703e
  DEPS_FUNC build_nodejs
  )
####################
function(build_nodejs)
  if(NOT (XP_DEFAULT OR XP_PRO_NODEJS))
    return()
  endif()
  find_package(Python)
  if(NOT Python_FOUND)
    message(FATAL_ERROR "Unable to build nodejs, required Python not found")
    return()
  endif()
  if(WIN32)
    if(NOT (XP_DEFAULT OR XP_PRO_NASM))
      message(STATUS "nodejs.cmake: requires nasm")
      set(XP_PRO_NASM ON CACHE BOOL "include nasm" FORCE)
      xpPatchProject(${PRO_NASM})
    endif()
  endif()
  set(NAME node)
  xpGetArgValue(${PRO_NODEJS} ARG VER VALUE VER)
  set(FIND_DEPS "set(nodeVer ${VER}) # for xpnode.cmake\n")
  set(TARGETS_FILE xpnode.cmake)
  string(TOUPPER ${NAME} PRJ)
  set(USE_VARS "set(${PRJ}_LIBRARIES xpro::${NAME})\n")
  set(USE_VARS "${USE_VARS}set(${PRJ}_EXE \${XP_ROOTDIR}/bin/${NAME}\${CMAKE_EXECUTABLE_SUFFIX})\n")
  set(USE_VARS "${USE_VARS}list(APPEND reqVars ${PRJ}_LIBRARIES ${PRJ}_EXE)\n")
  configure_file(${MODULES_DIR}/usexp.cmake.in
    ${STAGE_DIR}/share/cmake/usexp-${NAME}-config.cmake
    @ONLY NEWLINE_STYLE LF
    )
  configure_file(${MODULES_DIR}/xpnode.cmake ${STAGE_DIR}/share/cmake/ COPYONLY)
  if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm")
    if(${BUILD_PLATFORM} STREQUAL "64")
      set(destcpu arm64)
    elseif(${BUILD_PLATFORM} STREQUAL "32")
      set(destcpu arm)
    endif()
  elseif(${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64")
    set(destcpu arm64)
  else()
    if(${BUILD_PLATFORM} STREQUAL "64")
      set(destcpu x64)
    elseif(${BUILD_PLATFORM} STREQUAL "32")
      set(destcpu ia32)
    else()
      message(FATAL_ERROR "nodejs.cmake: cpu")
    endif()
  endif()
  if(MSVC)
    set(XP_CONFIGURE_BASE vcbuild)
    set(XP_CONFIGURE_Release ${XP_CONFIGURE_BASE} release ${destcpu})
    set(XP_CONFIGURE_Debug ${XP_CONFIGURE_BASE} debug ${destcpu})
  elseif(UNIX)
    if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
      set(destos linux)
    elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
      set(destos mac)
    else()
      message(FATAL_ERROR "nodejs.cmake: os")
    endif()
    list(APPEND XP_CONFIGURE_BASE <SOURCE_DIR>/configure
      --prefix=<INSTALL_DIR>
      --without-etw --without-dtrace
      # TODO: explore --tag=TAG custom build tag
      # TODO: explore --fully-static
      --dest-cpu=${destcpu} --dest-os=${destos}
      )
    set(XP_CONFIGURE_Release ${XP_CONFIGURE_BASE})
    set(XP_CONFIGURE_Debug ${XP_CONFIGURE_BASE} --debug --gdb)
  else()
    message(FATAL_ERROR "nodejs.cmake: unsupported OS platform")
  endif()
  set(nodejs_DEPS nodejs)
  # TODO: support Debug by renaming files going into STAGE_DIR?
  set(BUILD_CONFIGS Release)
  foreach(cfg ${BUILD_CONFIGS})
    set(XP_CONFIGURE_CMD ${XP_CONFIGURE_${cfg}})
    addproject_nodejs(nodejs ${cfg})
  endforeach() # cfg
  # copy headers to STAGE_DIR
  ExternalProject_Get_Property(nodejs SOURCE_DIR)
  set(nodejsHdrs ${SOURCE_DIR}/src/*.h)
  set(uvDir ${SOURCE_DIR}/deps/uv/include)
  set(v8Hdrs ${SOURCE_DIR}/deps/v8/include/*.h)
  set(cppgcHdrs ${SOURCE_DIR}/deps/v8/include/cppgc/*.h)
  set(XP_TARGET nodejs_stage)
  if(NOT TARGET ${XP_TARGET})
    ExternalProject_Add(${XP_TARGET} DEPENDS ${nodejs_DEPS}
      DOWNLOAD_DIR ${NULL_DIR} BINARY_DIR ${NULL_DIR}
      SOURCE_DIR ${NULL_DIR} INSTALL_DIR ${STAGE_DIR}/include/node_${VER}/node
      DOWNLOAD_COMMAND ${CMAKE_COMMAND} -E copy_directory ${uvDir} <INSTALL_DIR>
      CONFIGURE_COMMAND ${CMAKE_COMMAND} -Dsrc:STRING=${nodejsHdrs}
        -Ddst:STRING=<INSTALL_DIR> -P ${MODULES_DIR}/cmscopyfiles.cmake
      BUILD_COMMAND ${CMAKE_COMMAND} -Dsrc:STRING=${v8Hdrs}
        -Ddst:STRING=<INSTALL_DIR> -P ${MODULES_DIR}/cmscopyfiles.cmake
      INSTALL_COMMAND ${CMAKE_COMMAND} -Dsrc:STRING=${cppgcHdrs}
        -Ddst:STRING=<INSTALL_DIR>/cppgc -P ${MODULES_DIR}/cmscopyfiles.cmake
      )
    set_property(TARGET ${XP_TARGET} PROPERTY FOLDER ${bld_folder})
  endif()
endfunction()
####################
macro(addproject_nodejs basename cfg)
  set(XP_TARGET ${basename}_${cfg})
  ExternalProject_Get_Property(${basename} SOURCE_DIR)
  set(nodejsSrcDir ${SOURCE_DIR})
  if(NOT TARGET ${XP_TARGET})
    if(XP_BUILD_VERBOSE)
      message(STATUS "target ${XP_TARGET}")
      xpVerboseListing("[CONFIGURE]" "${XP_CONFIGURE_CMD}")
    else()
      message(STATUS "target ${XP_TARGET}")
    endif()
    if(MSVC)
      # TRICKY: vcbuild doesn't seem to return a good exit status or something...
      #   MSVC thinks it always needs to build this (after what appears to be a
      #   successful build) -- and there can't be any external project steps
      #   after the step with vcbuild or they won't execute
      ExternalProject_Add(${XP_TARGET}vcbuild DEPENDS ${nodejs_DEPS}
        DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
        SOURCE_DIR ${nodejsSrcDir} INSTALL_DIR ${NULL_DIR}
        CONFIGURE_COMMAND ${XP_CONFIGURE_CMD}
        BUILD_IN_SOURCE 1 # <BINARY_DIR>==<SOURCE_DIR>
        )
      set_property(TARGET ${XP_TARGET}vcbuild PROPERTY FOLDER ${bld_folder})
      list(APPEND nodejs_DEPS ${XP_TARGET}vcbuild) # serialize the build
      set(binNode <SOURCE_DIR>/${cfg}/node.exe)
      set(libNode <SOURCE_DIR>/${cfg}/node.lib)
      set(XP_CONFIGURE_CMD ${CMAKE_COMMAND} -E echo "Configure MSVC...")
      set(XP_BUILD_CMD ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/lib)
      set(XP_INSTALL_CMD ${CMAKE_COMMAND} -E copy ${libNode} ${STAGE_DIR}/lib)
    elseif(UNIX)
      set(binNode <SOURCE_DIR>/out/${cfg}/node)
      set(XP_BUILD_CMD)   # use default
      set(XP_INSTALL_CMD) # use default
    endif()
    ExternalProject_Add(${XP_TARGET} DEPENDS ${nodejs_DEPS}
      DOWNLOAD_COMMAND "" DOWNLOAD_DIR ${NULL_DIR}
      SOURCE_DIR ${nodejsSrcDir} INSTALL_DIR ${NULL_DIR}
      CONFIGURE_COMMAND ${XP_CONFIGURE_CMD}
      BUILD_COMMAND ${XP_BUILD_CMD}
      BUILD_IN_SOURCE 1 # <BINARY_DIR>==<SOURCE_DIR>
      INSTALL_COMMAND ${XP_INSTALL_CMD}
      )
    ExternalProject_Add_Step(${XP_TARGET} copy_bin
      COMMAND ${CMAKE_COMMAND} -E make_directory ${STAGE_DIR}/bin
      COMMAND ${CMAKE_COMMAND} -E copy ${binNode} ${STAGE_DIR}/bin
      DEPENDEES install
      )
    set_property(TARGET ${XP_TARGET} PROPERTY FOLDER ${bld_folder})
  endif()
  list(APPEND nodejs_DEPS ${XP_TARGET}) # serialize the build
endmacro()
