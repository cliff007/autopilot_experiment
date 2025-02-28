# ------------------------------------------------------------------------------------
# Helper to use PCL from outside project
#
# target_link_libraries(my_fabulous_target PCL_XXX_LIBRARIES) where XXX is the 
# upper cased xxx from : 
# 
# - common
# - octree
# - io
# - kdtree
# - search
# - sample_consensus
# - filters
# - 2d
# - geometry
# - features
# - ml
# - segmentation
# - visualization
# - surface
# - registration
# - keypoints
# - tracking
# - recognition
# - stereo
# - outofcore
# - people
#
# PCL_INCLUDE_DIRS is filled with PCL and available 3rdparty headers
# PCL_LIBRARY_DIRS is filled with PCL components libraries install directory and
# 3rdparty libraries paths
# 
#                                   www.pointclouds.org
#------------------------------------------------------------------------------------

### ---[ some useful macros
macro(pcl_report_not_found _reason)
  unset(PCL_FOUND)
  unset(PCL_LIBRARIES)
  unset(PCL_INCLUDE_DIRS)
  unset(PCL_LIBRARY_DIRS)
  unset(PCL_DEFINITIONS)
  if(PCL_FIND_REQUIRED)
    message(FATAL_ERROR ${_reason})
  elseif(NOT PCL_FIND_QUIETLY)
    message(WARNING ${_reason})
  endif()
  return()
endmacro(pcl_report_not_found)

macro(pcl_message)
  if(NOT PCL_FIND_QUIETLY)
    message(${ARGN})
  endif(NOT PCL_FIND_QUIETLY)
endmacro(pcl_message)

# Remove duplicate libraries    
macro(pcl_remove_duplicate_libraries _unfiltered_libraries _filtered_libraries)
  set(${_filtered_libraries})
  set(_debug_libraries)
  set(_optimized_libraries)
  set(_other_libraries)
  set(_waiting_for_debug 0)
  set(_waiting_for_optimized 0)
  set(_library_position -1)
  foreach(library ${${_unfiltered_libraries}})
    if("${library}" STREQUAL "debug")
      set(_waiting_for_debug 1)
    elseif("${library}" STREQUAL "optimized")
      set(_waiting_for_optimized 1)
    elseif(_waiting_for_debug)
      list(FIND _debug_libraries "${library}" library_position)
      if(library_position EQUAL -1)
        list(APPEND ${_filtered_libraries} debug ${library})
        list(APPEND _debug_libraries ${library})
      endif()
      set(_waiting_for_debug 0)
    elseif(_waiting_for_optimized)
      list(FIND _optimized_libraries "${library}" library_position)
      if(library_position EQUAL -1)
        list(APPEND ${_filtered_libraries} optimized ${library})
        list(APPEND _optimized_libraries ${library})
      endif()
      set(_waiting_for_optimized 0)
    else("${library}" STREQUAL "debug")
      list(FIND _other_libraries "${library}" library_position)
      if(library_position EQUAL -1)
        list(APPEND ${_filtered_libraries} ${library})
        list(APPEND _other_libraries ${library})
      endif()
    endif("${library}" STREQUAL "debug")
  endforeach(library)
endmacro(pcl_remove_duplicate_libraries)

### ---[ 3rd party libraries
macro(find_boost)
  if(PCL_ALL_IN_ONE_INSTALLER)
    set(BOOST_ROOT "${PCL_ROOT}/3rdParty/Boost")
  elseif(NOT BOOST_INCLUDEDIR)
    set(BOOST_INCLUDEDIR "D:/code/3rdparty/src/boost_1_55_0")
  endif(PCL_ALL_IN_ONE_INSTALLER)
  # use static Boost in Windows
  if(WIN32)
    set(Boost_USE_STATIC_LIBS ON)
    set(Boost_USE_STATIC ON)
    set(Boost_USE_MULTITHREAD )
  endif(WIN32)
  if(${CMAKE_VERSION} VERSION_LESS 2.8.5)
    SET(Boost_ADDITIONAL_VERSIONS "1.43" "1.43.0" "1.44" "1.44.0" "1.45" "1.45.0" "1.46.1" "1.46.0" "1.46" "1.47" "1.47.0")
  else(${CMAKE_VERSION} VERSION_LESS 2.8.5)
    SET(Boost_ADDITIONAL_VERSIONS "1.47" "1.47.0")
  endif(${CMAKE_VERSION} VERSION_LESS 2.8.5)
  # Disable the config mode of find_package(Boost)
  set(Boost_NO_BOOST_CMAKE ON)
  find_package(Boost 1.40.0 ${QUIET_} COMPONENTS system filesystem thread date_time iostreams chrono)

  set(BOOST_FOUND ${Boost_FOUND})
  set(BOOST_INCLUDE_DIRS "${Boost_INCLUDE_DIR}")
  set(BOOST_LIBRARY_DIRS "${Boost_LIBRARY_DIRS}")
  set(BOOST_LIBRARIES ${Boost_LIBRARIES})
  if(WIN32 AND NOT MINGW)
    set(BOOST_DEFINITIONS ${BOOST_DEFINITIONS} -DBOOST_ALL_NO_LIB)
  endif(WIN32 AND NOT MINGW)
endmacro(find_boost)

#remove this as soon as eigen is shipped with FindEigen.cmake
macro(find_eigen)
  if(PCL_ALL_IN_ONE_INSTALLER)
    set(EIGEN_ROOT "${PCL_ROOT}/3rdParty/Eigen")
  elseif(NOT EIGEN_ROOT)
    get_filename_component(EIGEN_ROOT "D:\code\3rdparty\src\eigen-eigen-bdd17ee3b1b3" ABSOLUTE)
  endif(PCL_ALL_IN_ONE_INSTALLER)
  if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_EIGEN eigen3)
  endif(PKG_CONFIG_FOUND)
  find_path(EIGEN_INCLUDE_DIRS Eigen/Core
    HINTS ${PC_EIGEN_INCLUDEDIR} ${PC_EIGEN_INCLUDE_DIRS} 
          "${EIGEN_ROOT}" "$ENV{EIGEN_ROOT}"
    PATHS "$ENV{PROGRAMFILES}/Eigen 3.0.0" "$ENV{PROGRAMW6432}/Eigen 3.0.0"
          "$ENV{PROGRAMFILES}/Eigen" "$ENV{PROGRAMW6432}/Eigen"   
    PATH_SUFFIXES eigen3 include/eigen3 include)
  find_package_handle_standard_args(eigen DEFAULT_MSG EIGEN_INCLUDE_DIRS)
  set(EIGEN_DEFINITIONS ${EIGEN_DEFINITIONS} -DEIGEN_USE_NEW_STDVECTOR 
      -DEIGEN_YES_I_KNOW_SPARSE_MODULE_IS_NOT_STABLE_YET)
endmacro(find_eigen)

#remove this as soon as qhull is shipped with FindQhull.cmake
macro(find_qhull)
  if(PCL_ALL_IN_ONE_INSTALLER)
    set(QHULL_ROOT "${PCL_ROOT}/3rdParty/Qhull")
  elseif(NOT QHULL_ROOT)
    get_filename_component(QHULL_ROOT "" PATH)
  endif(PCL_ALL_IN_ONE_INSTALLER)
  set(QHULL_MAJOR_VERSION 6)

  find_path(QHULL_INCLUDE_DIRS
    NAMES libqhull/libqhull.h qhull.h
    HINTS "${QHULL_ROOT}" "$ENV{QHULL_ROOT}"
    PATHS "$ENV{PROGRAMFILES}/qhull" "$ENV{PROGRAMW6432}/qhull" 
    PATH_SUFFIXES qhull src/libqhull libqhull include)

  # Most likely we are on windows so prefer static libraries over shared ones (Mourad's recommend)
  find_library(QHULL_LIBRARY 
    NAMES ""
    HINTS "${QHULL_ROOT}" "$ENV{QHULL_ROOT}"
    PATHS "$ENV{PROGRAMFILES}/qhull" "$ENV{PROGRAMW6432}/qhull" 
    PATH_SUFFIXES project build bin lib)
  
  find_library(QHULL_LIBRARY_DEBUG 
    NAMES ""
    HINTS "${QHULL_ROOT}" "$ENV{QHULL_ROOT}"
    PATHS "$ENV{PROGRAMFILES}/qhull" "$ENV{PROGRAMW6432}/qhull" 
    PATH_SUFFIXES project build bin lib)
  
  find_package_handle_standard_args(qhull DEFAULT_MSG QHULL_LIBRARY QHULL_INCLUDE_DIRS)

  if(QHULL_FOUND)
    get_filename_component(QHULL_LIBRARY_PATH ${QHULL_LIBRARY} PATH)
    if(QHULL_LIBRARY_DEBUG)
      set(QHULL_LIBRARIES optimized ${QHULL_LIBRARY} debug ${QHULL_LIBRARY_DEBUG})
      get_filename_component(QHULL_LIBRARY_DEBUG_PATH ${QHULL_LIBRARY_DEBUG} PATH)
      set(QHULL_LIBRARY_DIRS ${QHULL_LIBRARY_PATH} ${QHULL_LIBRARY_DEBUG_PATH}) 
    else(QHULL_LIBRARY_DEBUG)
      set(QHULL_LIBRARIES ${QHULL_LIBRARY})
      set(QHULL_LIBRARY_DIRS ${QHULL_LIBRARY_PATH}) 
    endif(QHULL_LIBRARY_DEBUG)
    set(QHULL_DEFINITIONS)
    get_filename_component(qhull_lib ${QHULL_LIBRARY} NAME_WE)
    if(NOT "${qhull_lib}" MATCHES "qhullstatic")
      set(QHULL_DEFINITIONS ${QHULL_DEFINITIONS} -Dqh_QHpointer)
      if(MSVC)
        set(QHULL_DEFINITIONS ${QHULL_DEFINITIONS} -Dqh_QHpointer_dllimport)
      endif(MSVC)
    endif(NOT "${qhull_lib}" MATCHES "qhullstatic")
  endif(QHULL_FOUND)
endmacro(find_qhull)

#remove this as soon as libopenni is shipped with FindOpenni.cmake
macro(find_openni)
  if(NOT OPENNI_ROOT AND ("" STREQUAL "TRUE"))
    set(OPENNI_INCLUDE_DIRS_HINT "")
    get_filename_component(OPENNI_LIBRARY_HINT "OPENNI_LIBRARY-NOTFOUND" PATH)
  endif()

  if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_OPENNI libopenni)
  endif(PKG_CONFIG_FOUND)
  find_path(OPENNI_INCLUDE_DIRS XnStatus.h
    HINTS ${PC_OPENNI_INCLUDEDIR} ${PC_OPENNI_INCLUDE_DIRS} 
          "${OPENNI_ROOT}" "$ENV{OPENNI_ROOT}"
    PATHS "$ENV{OPEN_NI_INCLUDE}" "${OPENNI_INCLUDE_DIRS_HINT}"
    PATH_SUFFIXES include/openni Include)
  #add a hint so that it can find it without the pkg-config
  set(OPENNI_SUFFIX)
  if(WIN32 AND CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(OPENNI_SUFFIX 64)
  endif(WIN32 AND CMAKE_SIZEOF_VOID_P EQUAL 8)
  find_library(OPENNI_LIBRARY 
    NAMES OpenNI64 OpenNI 
    HINTS ${PC_OPENNI_LIBDIR} ${PC_OPENNI_LIBRARY_DIRS} 
          "${OPENNI_ROOT}" "$ENV{OPENNI_ROOT}"
    PATHS "$ENV{OPEN_NI_LIB${OPENNI_SUFFIX}}" "${OPENNI_LIBRARY_HINT}"
    PATH_SUFFIXES lib Lib Lib64)

  find_package_handle_standard_args(openni DEFAULT_MSG OPENNI_LIBRARY OPENNI_INCLUDE_DIRS)

  if(OPENNI_FOUND)
    get_filename_component(OPENNI_LIBRARY_PATH ${OPENNI_LIBRARY} PATH)
    set(OPENNI_LIBRARY_DIRS ${OPENNI_LIBRARY_PATH}) 
    set(OPENNI_LIBRARIES "${OPENNI_LIBRARY}")
  endif(OPENNI_FOUND)
endmacro(find_openni)

#remove this as soon as libopenni2 is shipped with FindOpenni2.cmake
macro(find_openni2)
  if(PCL_FIND_QUIETLY)
	set(OpenNI2_FIND_QUIETLY TRUE)
  endif()

  if(NOT OPENNI2_ROOT AND ("" STREQUAL "TRUE"))
    set(OPENNI2_INCLUDE_DIRS_HINT "OPENNI2_INCLUDE_DIRS-NOTFOUND")
    get_filename_component(OPENNI2_LIBRARY_HINT "OPENNI2_LIBRARY-NOTFOUND" PATH)
  endif()

  set(OPENNI2_SUFFIX)
  if(WIN32 AND CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(OPENNI2_SUFFIX 64)
  endif(WIN32 AND CMAKE_SIZEOF_VOID_P EQUAL 8)
  
  if(PKG_CONFIG_FOUND)
	if(PCL_FIND_QUIETLY)
    	pkg_check_modules(PC_OPENNI2 QUIET libopenni2)
	else()
		pkg_check_modules(PC_OPENNI2 libopenni2)
	endif()
  endif(PKG_CONFIG_FOUND)
  
  find_path(OPENNI2_INCLUDE_DIRS OpenNI.h
          HINTS /usr/include/openni2 /usr/include/ni2 /usr/local/include/openni2 /usr/local/include/ni2
          PATHS "$ENV{OPENNI2_INCLUDE${OPENNI2_SUFFIX}}" "${OPENNI2_INCLUDE_DIRS_HINT}"
          PATH_SUFFIXES openni openni2 include Include)
  
  find_library(OPENNI2_LIBRARY 
             NAMES OpenNI2	# No suffix needed on Win64
             HINTS /usr/lib /usr/local/lib/ni2
             PATHS "$ENV{OPENNI2_LIB${OPENNI2_SUFFIX}}" "${OPENNI2_LIBRARY_HINT}"
             PATH_SUFFIXES lib Lib Lib64)	
  
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(OpenNI2 DEFAULT_MSG OPENNI2_LIBRARY OPENNI2_INCLUDE_DIRS)
  
  if(OPENNI2_FOUND)
    get_filename_component(OPENNI2_LIBRARY_PATH ${OPENNI2_LIBRARY} PATH)
    set(OPENNI2_LIBRARY_DIRS ${OPENNI2_LIBRARY_PATH}) 
    set(OPENNI2_LIBRARIES "${OPENNI2_LIBRARY}")
    set(OPENNI2_REDIST_DIR $ENV{OPENNI2_REDIST${OPENNI2_SUFFIX}})
  endif(OPENNI2_FOUND)
endmacro(find_openni2)

#remove this as soon as the Ensenso SDK is shipped with FindEnsenso.cmake
macro(find_ensenso)
  if(PCL_FIND_QUIETLY)
	set(ensenso_FIND_QUIETLY TRUE)
  endif()

  if(NOT ENSENSO_ROOT AND ("" STREQUAL "TRUE"))
    get_filename_component(ENSENSO_ABI_HINT ENSENSO_INCLUDE_DIR-NOTFOUND PATH)
  endif()

  find_path(ENSENSO_INCLUDE_DIR nxLib.h
            HINTS ${ENSENSO_ABI_HINT}
            /opt/ensenso/development/c
            "$ENV{PROGRAMFILES}/Ensenso/development/c" "$ENV{PROGRAMW6432}/Ensenso/development/c"
            PATH_SUFFIXES include/)

  find_library(ENSENSO_LIBRARY QUIET NAMES NxLib64 NxLib32 nxLib64 nxLib32
               HINTS ${ENSENSO_ABI_HINT}
               "$ENV{PROGRAMFILES}/Ensenso/development/c" "$ENV{PROGRAMW6432}/Ensenso/development/c"
               PATH_SUFFIXES lib/)

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(ensenso DEFAULT_MSG
                                    ENSENSO_LIBRARY ENSENSO_INCLUDE_DIR)

  if(ENSENSO_FOUND)
    get_filename_component(ENSENSO_LIBRARY_PATH ${ENSENSO_LIBRARY} PATH)
    set(ENSENSO_INCLUDE_DIRS ${ENSENSO_INCLUDE_DIR})
    set(ENSENSO_LIBRARY_DIRS ${ENSENSO_LIBRARY_PATH})
    set(ENSENSO_LIBRARIES "${ENSENSO_LIBRARY}")
    set(ENSENSO_REDIST_DIR $ENV{ENSENSO_REDIST${ENSENSO_SUFFIX}})
  endif(ENSENSO_FOUND)
endmacro(find_ensenso)

#remove this as soon as the davidSDK is shipped with FinddavidSDK.cmake
macro(find_davidSDK)
  if(PCL_FIND_QUIETLY)
	set(DAVIDSDK_FIND_QUIETLY TRUE)
  endif()

  if(NOT davidSDK_ROOT AND ("" STREQUAL "TRUE"))
    get_filename_component(DAVIDSDK_ABI_HINT DAVIDSDK_INCLUDE_DIR-NOTFOUND PATH)
  endif()

  find_path(DAVIDSDK_INCLUDE_DIR david.h
            HINTS ${DAVIDSDK_ABI_HINT}
            /usr/local/include/davidSDK
            "$ENV{PROGRAMFILES}/davidSDK" "$ENV{PROGRAMW6432}/davidSDK"
            PATH_SUFFIXES include/)

  find_library(DAVIDSDK_LIBRARY QUIET NAMES davidSDK
               HINTS ${DAVIDSDK_ABI_HINT}
               "$ENV{PROGRAMFILES}/davidSDK" "$ENV{PROGRAMW6432}/davidSDK"
               PATH_SUFFIXES lib/)

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(DAVIDSDK DEFAULT_MSG
                                    DAVIDSDK_LIBRARY DAVIDSDK_INCLUDE_DIR)

  if(DAVIDSDK_FOUND)
    get_filename_component(DAVIDSDK_LIBRARY_PATH ${DAVIDSDK_LIBRARY} PATH)
    set(DAVIDSDK_INCLUDE_DIRS ${DAVIDSDK_INCLUDE_DIR})
    set(DAVIDSDK_LIBRARY_DIRS ${DAVIDSDK_LIBRARY_PATH})
    set(DAVIDSDK_LIBRARIES "${DAVIDSDK_LIBRARY}")
    set(DAVIDSDK_REDIST_DIR $ENV{DAVIDSDK_REDIST${DAVIDSDK_SUFFIX}})
  endif(DAVIDSDK_FOUND)
endmacro(find_davidSDK)

macro(find_dssdk)
  if(PCL_FIND_QUIETLY)
	set(DSSDK_FIND_QUIETLY TRUE)
  endif()
  if(NOT DSSDK_DIR AND ("" STREQUAL "TRUE"))
    get_filename_component(DSSDK_DIR_HINT "" PATH)
  endif()
  find_path(DSSDK_DIR include/DepthSenseVersion.hxx
            HINTS ${DSSDK_DIR_HINT}
                  "$ENV{DEPTHSENSESDK32}"
                  "$ENV{DEPTHSENSESDK64}"
            PATHS "$ENV{PROGRAMFILES}/SoftKinetic/DepthSenseSDK"
                  "$ENV{PROGRAMW6432}/SoftKinetic/DepthSenseSDK"
                  "C:/Program Files (x86)/SoftKinetic/DepthSenseSDK"
                  "C:/Program Files/SoftKinetic/DepthSenseSDK"
                  "/opt/softkinetic/DepthSenseSDK"
            DOC "DepthSense SDK directory")
  set(_DSSDK_INCLUDE_DIRS ${DSSDK_DIR}/include)
  if(MSVC)
    set(DSSDK_LIBRARIES_NAMES DepthSense)
  else()
    set(DSSDK_LIBRARIES_NAMES DepthSense DepthSensePlugins turbojpeg)
  endif()
  foreach(LIB ${DSSDK_LIBRARIES_NAMES})
    find_library(DSSDK_LIBRARY_${LIB}
                 NAMES "${LIB}"
                 PATHS "${DSSDK_DIR}/lib/" NO_DEFAULT_PATH)
    list(APPEND _DSSDK_LIBRARIES ${DSSDK_LIBRARY_${LIB}})
    mark_as_advanced(DSSDK_LIBRARY_${LIB})
  endforeach()
  find_package_handle_standard_args(DSSDK DEFAULT_MSG _DSSDK_LIBRARIES _DSSDK_INCLUDE_DIRS)
  if(DSSDK_FOUND)
    set(DSSDK_LIBRARIES ${_DSSDK_LIBRARIES})
    mark_as_advanced(DSSDK_LIBRARIES)
    set(DSSDK_INCLUDE_DIRS ${_DSSDK_INCLUDE_DIRS})
    mark_as_advanced(DSSDK_INCLUDE_DIRS)
  endif()
endmacro(find_dssdk)

macro(find_rssdk)
  if(PCL_FIND_QUIETLY)
	set(RSSDK_FIND_QUIETLY TRUE)
  endif()
  if(NOT RSSDK_DIR AND ("" STREQUAL "TRUE"))
    get_filename_component(RSSDK_DIR_HINT "" PATH)
  endif()
  find_path(RSSDK_DIR include/pxcversion.h
            HINTS ${RSSDK_DIR_HINT}
            PATHS "$ENV{RSSDK_DIR}"
                  "$ENV{PROGRAMFILES}/Intel/RSSDK"
                  "$ENV{PROGRAMW6432}/Intel/RSSDK"
                  "C:/Program Files (x86)/Intel/RSSDK"
                  "C:/Program Files/Intel/RSSDK"
            DOC "RealSense SDK directory")
  set(_RSSDK_INCLUDE_DIRS ${RSSDK_DIR}/include)
  set(RSSDK_RELEASE_NAME libpxc.lib)
  set(RSSDK_DEBUG_NAME libpxc_d.lib)
  find_library(RSSDK_LIBRARY
               NAMES ${RSSDK_RELEASE_NAME}
               PATHS "${RSSDK_DIR}/lib/" NO_DEFAULT_PATH
               PATH_SUFFIXES x64 Win32)
  find_library(RSSDK_LIBRARY_DEBUG
               NAMES ${RSSDK_DEBUG_NAME} ${RSSDK_RELEASE_NAME}
               PATHS "${RSSDK_DIR}/lib/" NO_DEFAULT_PATH
               PATH_SUFFIXES x64 Win32)
  if(NOT RSSDK_LIBRARY_DEBUG)
    set(RSSDK_LIBRARY_DEBUG ${RSSDK_LIBRARY})
  endif()
  set(_RSSDK_LIBRARIES optimized ${RSSDK_LIBRARY} debug ${RSSDK_LIBRARY_DEBUG})
  mark_as_advanced(RSSDK_LIBRARY RSSDK_LIBRARY_DEBUG)
  find_package_handle_standard_args(RSSDK DEFAULT_MSG _RSSDK_LIBRARIES _RSSDK_INCLUDE_DIRS)
  if(RSSDK_FOUND)
    set(RSSDK_LIBRARIES ${_RSSDK_LIBRARIES})
    mark_as_advanced(RSSDK_LIBRARIES)
    set(RSSDK_INCLUDE_DIRS ${_RSSDK_INCLUDE_DIRS})
    mark_as_advanced(RSSDK_INCLUDE_DIRS)
  endif()
endmacro(find_rssdk)

#remove this as soon as flann is shipped with FindFlann.cmake
macro(find_flann)
  if(PCL_ALL_IN_ONE_INSTALLER)
    set(FLANN_ROOT "${PCL_ROOT}/3rdParty/Flann")
  elseif(NOT FLANN_ROOT)
    get_filename_component(FLANN_ROOT "D:/code/3rdparty/src/flann-1.8.4-src/src/cpp" PATH)
  endif(PCL_ALL_IN_ONE_INSTALLER)
  if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_FLANN flann)
  endif(PKG_CONFIG_FOUND)

  find_path(FLANN_INCLUDE_DIRS flann/flann.hpp
    HINTS ${PC_FLANN_INCLUDEDIR} ${PC_FLANN_INCLUDE_DIRS} 
          "${FLANN_ROOT}" "$ENV{FLANN_ROOT}"
    PATHS "$ENV{PROGRAMFILES}/flann 1.6.9" "$ENV{PROGRAMW6432}/flann 1.6.9"
          "$ENV{PROGRAMFILES}/flann" "$ENV{PROGRAMW6432}/flann"
    PATH_SUFFIXES include)

  find_library(FLANN_LIBRARY
    NAMES flann_cpp_s flann_cpp
    HINTS ${PC_FLANN_LIBDIR} ${PC_FLANN_LIBRARY_DIRS} "${FLANN_ROOT}" "$ENV{FLANN_ROOT}"
    PATHS "$ENV{PROGRAMFILES}/flann 1.6.9" "$ENV{PROGRAMW6432}/flann 1.6.9" 
          "$ENV{PROGRAMFILES}/flann" "$ENV{PROGRAMW6432}/flann"
    PATH_SUFFIXES lib)

  find_library(FLANN_LIBRARY_DEBUG 
    NAMES flann_cpp_s-gd flann_cpp-gd flann_cpp_s flann_cpp
    HINTS ${PC_FLANN_LIBDIR} ${PC_FLANN_LIBRARY_DIRS} "${FLANN_ROOT}" "$ENV{FLANN_ROOT}"
    PATHS "$ENV{PROGRAMFILES}/flann 1.6.9" "$ENV{PROGRAMW6432}/flann 1.6.9" 
          "$ENV{PROGRAMFILES}/flann" "$ENV{PROGRAMW6432}/flann"
    PATH_SUFFIXES lib)

  find_package_handle_standard_args(Flann DEFAULT_MSG FLANN_LIBRARY FLANN_INCLUDE_DIRS)
  if(FLANN_FOUND)
    get_filename_component(FLANN_LIBRARY_PATH ${FLANN_LIBRARY} PATH)
    if(FLANN_LIBRARY_DEBUG)
      get_filename_component(FLANN_LIBRARY_DEBUG_PATH ${FLANN_LIBRARY_DEBUG} PATH)
      set(FLANN_LIBRARY_DIRS ${FLANN_LIBRARY_PATH} ${FLANN_LIBRARY_DEBUG_PATH}) 
      set(FLANN_LIBRARIES optimized ${FLANN_LIBRARY} debug ${FLANN_LIBRARY_DEBUG})
    else(FLANN_LIBRARY_DEBUG)
      set(FLANN_LIBRARY_DIRS ${FLANN_LIBRARY_PATH}) 
      set(FLANN_LIBRARIES ${FLANN_LIBRARY})
    endif(FLANN_LIBRARY_DEBUG)
    if("${FLANN_LIBRARY}" MATCHES "flann_cpp_s")
      set(FLANN_DEFINITIONS ${FLANN_DEFINITIONS} -DFLANN_STATIC)
    endif("${FLANN_LIBRARY}" MATCHES "flann_cpp_s")
  endif(FLANN_FOUND)
endmacro(find_flann)

macro(find_VTK)
  if(PCL_ALL_IN_ONE_INSTALLER AND NOT ANDROID)
    if(EXISTS "${PCL_ROOT}/3rdParty/VTK/lib/cmake")
      set(VTK_DIR "${PCL_ROOT}/3rdParty/VTK/lib/cmake/vtk-7.0")
    else()
      set(VTK_DIR "${PCL_ROOT}/3rdParty/VTK/lib/vtk-7.0")
    endif()
  elseif(NOT VTK_DIR AND NOT ANDROID)
    set(VTK_DIR "D:/code/3rdparty/src/VTK-7.0.0/build")
  endif(PCL_ALL_IN_ONE_INSTALLER AND NOT ANDROID)
  if(NOT ANDROID)
    find_package(VTK ${QUIET_})
    if (VTK_FOUND)
      set(VTK_LIBRARIES "vtkChartsCore;vtkCommonColor;vtkCommonDataModel;vtkCommonMath;vtkCommonCore;vtksys;vtkCommonMisc;vtkCommonSystem;vtkCommonTransforms;vtkInfovisCore;vtkFiltersExtraction;vtkCommonExecutionModel;vtkFiltersCore;vtkFiltersGeneral;vtkCommonComputationalGeometry;vtkFiltersStatistics;vtkImagingFourier;vtkImagingCore;vtkalglib;vtkRenderingContext2D;vtkRenderingCore;vtkFiltersGeometry;vtkFiltersSources;vtkRenderingFreeType;vtkfreetype;vtkzlib;vtkDICOMParser;vtkDomainsChemistry;vtkIOXML;vtkIOGeometry;vtkIOCore;vtkIOXMLParser;vtkexpat;vtkDomainsChemistryOpenGL2;vtkRenderingOpenGL2;vtkImagingHybrid;vtkIOImage;vtkmetaio;vtkjpeg;vtkpng;vtktiff;vtkglew;vtkFiltersAMR;vtkParallelCore;vtkIOLegacy;vtkFiltersFlowPaths;vtkFiltersGeneric;vtkFiltersHybrid;vtkImagingSources;vtkFiltersHyperTree;vtkFiltersImaging;vtkImagingGeneral;vtkFiltersModeling;vtkFiltersParallel;vtkFiltersParallelImaging;vtkFiltersProgrammable;vtkFiltersSMP;vtkFiltersSelection;vtkFiltersTexture;vtkFiltersVerdict;verdict;vtkGeovisCore;vtkInfovisLayout;vtkInteractionStyle;vtkInteractionWidgets;vtkRenderingAnnotation;vtkImagingColor;vtkRenderingVolume;vtkViewsCore;vtkproj4;vtkIOAMR;vtkhdf5_hl;vtkhdf5;vtkIOEnSight;vtkIOExodus;vtkexoIIc;vtkNetCDF;vtkNetCDF_cxx;vtkIOExport;vtkRenderingLabel;vtkIOImport;vtkIOInfovis;vtklibxml2;vtkIOLSDyna;vtkIOMINC;vtkIOMovie;vtkoggtheora;vtkIONetCDF;vtkIOPLY;vtkIOParallel;vtkjsoncpp;vtkIOParallelXML;vtkIOSQL;vtksqlite;vtkIOVideo;vtkImagingMath;vtkImagingMorphological;vtkImagingStatistics;vtkImagingStencil;vtkInteractionImage;vtkRenderingContextOpenGL2;vtkRenderingImage;vtkRenderingLOD;vtkRenderingVolumeOpenGL2;vtkViewsContext2D;vtkViewsInfovis")
    endif(VTK_FOUND)
  endif()
endmacro(find_VTK)

macro(find_libusb)
  if(NOT WIN32)
    find_path(LIBUSB_1_INCLUDE_DIR
      NAMES libusb-1.0/libusb.h
      PATHS /usr/include /usr/local/include /opt/local/include /sw/include
      PATH_SUFFIXES libusb-1.0)

    find_library(LIBUSB_1_LIBRARY
      NAMES usb-1.0
      PATHS /usr/lib /usr/local/lib /opt/local/lib /sw/lib)
    find_package_handle_standard_args(libusb-1.0 LIBUSB_1_LIBRARY LIBUSB_1_INCLUDE_DIR)
  endif(NOT WIN32)
endmacro(find_libusb)

macro(find_glew)
IF (WIN32)

  IF(CYGWIN)

    FIND_PATH( GLEW_INCLUDE_DIR GL/glew.h)

    FIND_LIBRARY( GLEW_GLEW_LIBRARY glew32
      ${OPENGL_LIBRARY_DIR}
      /usr/lib/w32api
      /usr/X11R6/lib
    )


  ELSE(CYGWIN)

    FIND_PATH( GLEW_INCLUDE_DIR GL/glew.h
      $ENV{GLEW_ROOT}/include
    )

    FIND_LIBRARY( GLEW_GLEW_LIBRARY
      NAMES glew glew32 glew32s
      PATHS
      $ENV{GLEW_ROOT}/lib
      ${OPENGL_LIBRARY_DIR}
    )

  ENDIF(CYGWIN)

ELSE (WIN32)

  IF (APPLE)
  
    FIND_PATH( GLEW_INCLUDE_DIR GL/glew.h
      /usr/local/include
      /System/Library/Frameworks/GLEW.framework/Versions/A/Headers
      ${OPENGL_LIBRARY_DIR}
    )

    FIND_LIBRARY( GLEW_GLEW_LIBRARY GLEW
      /usr/local/lib
      /usr/openwin/lib
      /usr/X11R6/lib
    )

    if(NOT GLEW_GLEW_LIBRARY)
        SET(GLEW_GLEW_LIBRARY "-framework GLEW" CACHE STRING "GLEW library for OSX")
        SET(GLEW_cocoa_LIBRARY "-framework Cocoa" CACHE STRING "Cocoa framework for OSX")
    endif()
  ELSE (APPLE)

    FIND_PATH( GLEW_INCLUDE_DIR GL/glew.h
      /usr/include/GL
      /usr/openwin/share/include
      /usr/openwin/include
      /usr/X11R6/include
      /usr/include/X11
      /opt/graphics/OpenGL/include
      /opt/graphics/OpenGL/contrib/libglew
    )

    FIND_LIBRARY( GLEW_GLEW_LIBRARY GLEW
      /usr/openwin/lib
      /usr/X11R6/lib
    )

  ENDIF (APPLE)

ENDIF (WIN32)

SET( GLEW_FOUND FALSE )
IF(GLEW_INCLUDE_DIR)
  IF(GLEW_GLEW_LIBRARY)
    # Is -lXi and -lXmu required on all platforms that have it?
    # If not, we need some way to figure out what platform we are on.
    SET( GLEW_LIBRARIES
      ${GLEW_GLEW_LIBRARY}
      ${GLEW_cocoa_LIBRARY}
    )
    SET( GLEW_FOUND TRUE )

#The following deprecated settings are for backwards compatibility with CMake1.4
    SET (GLEW_LIBRARY ${GLEW_LIBRARIES})
    SET (GLEW_INCLUDE_PATH ${GLEW_INCLUDE_DIR})

  ENDIF(GLEW_GLEW_LIBRARY)
ENDIF(GLEW_INCLUDE_DIR)

IF(GLEW_FOUND)
  IF(NOT GLEW_FIND_QUIETLY)
    MESSAGE(STATUS "Found Glew: ${GLEW_LIBRARIES}")
  ENDIF(NOT GLEW_FIND_QUIETLY)
  IF(GLEW_GLEW_LIBRARY MATCHES glew32s)
    ADD_DEFINITIONS(-DGLEW_STATIC)
  ENDIF(GLEW_GLEW_LIBRARY MATCHES glew32s)
ELSE(GLEW_FOUND)
  IF(GLEW_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "Could not find Glew")
  ENDIF(GLEW_FIND_REQUIRED)
ENDIF(GLEW_FOUND)
endmacro(find_glew)

# Finds each component external libraries if any
# The functioning is as following
# try to find _lib
# |--> _lib found ==> include the headers,
# |                   link to its library directories or include _lib_USE_FILE
# `--> _lib not found
#                   |--> _lib is optional ==> disable it (thanks to the guardians) 
#                   |                         and warn
#                   `--> _lib is required
#                                       |--> component is required explicitely ==> error
#                                       `--> component is induced ==> warn and remove it
#                                                                     from the list

macro(find_external_library _component _lib _is_optional)
  if("${_lib}" STREQUAL "boost")
    find_boost()
  elseif("${_lib}" STREQUAL "eigen")
    find_eigen()
  elseif("${_lib}" STREQUAL "flann")
    find_flann()
  elseif("${_lib}" STREQUAL "qhull")
    find_qhull()
  elseif("${_lib}" STREQUAL "openni")
    find_openni()
  elseif("${_lib}" STREQUAL "openni2")
    find_openni2()
  elseif("${_lib}" STREQUAL "ensenso")
    find_ensenso()
  elseif("${_lib}" STREQUAL "davidSDK")
    find_davidSDK()
  elseif("${_lib}" STREQUAL "dssdk")
    find_dssdk()
  elseif("${_lib}" STREQUAL "rssdk")
    find_rssdk()
  elseif("${_lib}" STREQUAL "vtk")
    find_VTK()
  elseif("${_lib}" STREQUAL "libusb-1.0")
    find_libusb()
  elseif("${_lib}" STREQUAL "glew")
    find_glew()
  elseif("${_lib}" STREQUAL "opengl")
    find_package(OpenGL)
  endif("${_lib}" STREQUAL "boost")

  string(TOUPPER "${_component}" COMPONENT)
  string(TOUPPER "${_lib}" LIB)
  string(REGEX REPLACE "[.-]" "_" LIB ${LIB})
  if(${LIB}_FOUND)
    list(APPEND PCL_${COMPONENT}_INCLUDE_DIRS ${${LIB}_INCLUDE_DIRS})
    if(${LIB}_USE_FILE)
      include(${${LIB}_USE_FILE})
    else(${LIB}_USE_FILE)
      list(APPEND PCL_${COMPONENT}_LIBRARY_DIRS "${${LIB}_LIBRARY_DIRS}")
    endif(${LIB}_USE_FILE)
    if(${LIB}_LIBRARIES)
      list(APPEND PCL_${COMPONENT}_LIBRARIES "${${LIB}_LIBRARIES}")
    endif(${LIB}_LIBRARIES)
    if(${LIB}_DEFINITIONS AND NOT ${LIB} STREQUAL "VTK")
      list(APPEND PCL_${COMPONENT}_DEFINITIONS ${${LIB}_DEFINITIONS})
    endif(${LIB}_DEFINITIONS AND NOT ${LIB} STREQUAL "VTK")
  else(${LIB}_FOUND)
    if("${_is_optional}" STREQUAL "OPTIONAL")
      add_definitions("-DDISABLE_${LIB}")
      pcl_message("** WARNING ** ${_component} features related to ${_lib} will be disabled")
    elseif("${_is_optional}" STREQUAL "REQUIRED")
      if((NOT PCL_FIND_ALL) OR (PCL_FIND_ALL EQUAL 1))
        pcl_report_not_found("${_component} is required but ${_lib} was not found")
      elseif(PCL_FIND_ALL EQUAL 0)
        # raise error and remove _component from PCL_TO_FIND_COMPONENTS
        string(TOUPPER "${_component}" COMPONENT)
        pcl_message("** WARNING ** ${_component} will be disabled cause ${_lib} was not found")
        list(REMOVE_ITEM PCL_TO_FIND_COMPONENTS ${_component})
      endif((NOT PCL_FIND_ALL) OR (PCL_FIND_ALL EQUAL 1))
    endif("${_is_optional}" STREQUAL "OPTIONAL")
  endif(${LIB}_FOUND)
endmacro(find_external_library)

macro(pcl_check_external_dependency _component)
endmacro(pcl_check_external_dependency)

#flatten dependencies recursivity is great \o/
macro(compute_dependencies TO_FIND_COMPONENTS)
  foreach(component ${${TO_FIND_COMPONENTS}})
    set(pcl_component pcl_${component})
    if(${pcl_component}_int_dep AND (NOT PCL_FIND_ALL))
      foreach(dependency ${${pcl_component}_int_dep})
        list(FIND ${TO_FIND_COMPONENTS} ${component} pos)
        list(FIND ${TO_FIND_COMPONENTS} ${dependency} found)
        if(found EQUAL -1)
          set(pcl_dependency pcl_${dependency})
          if(${pcl_dependency}_int_dep)
            list(INSERT ${TO_FIND_COMPONENTS} ${pos} ${dependency})
            if(pcl_${dependency}_ext_dep)
              list(APPEND pcl_${component}_ext_dep ${pcl_${dependency}_ext_dep})
            endif(pcl_${dependency}_ext_dep)
            if(pcl_${dependency}_opt_dep)
              list(APPEND pcl_${component}_opt_dep ${pcl_${dependency}_opt_dep})
            endif(pcl_${dependency}_opt_dep)
            compute_dependencies(${TO_FIND_COMPONENTS})
          else(${pcl_dependency}_int_dep)
            list(INSERT ${TO_FIND_COMPONENTS} 0 ${dependency})
          endif(${pcl_dependency}_int_dep)
        endif(found EQUAL -1)
      endforeach(dependency)
    endif(${pcl_component}_int_dep AND (NOT PCL_FIND_ALL))
  endforeach(component)
endmacro(compute_dependencies)

### ---[ Find PCL

if(PCL_FIND_QUIETLY)
  set(QUIET_ QUIET)
else(PCL_FIND_QUIETLY)
  set(QUIET_)
endif(PCL_FIND_QUIETLY)

find_package(PkgConfig QUIET)

file(TO_CMAKE_PATH "${PCL_DIR}" PCL_DIR)
if(WIN32 AND NOT MINGW)
# PCLConfig.cmake is installed to PCL_ROOT/cmake
  get_filename_component(PCL_ROOT "${PCL_DIR}" PATH)
else(WIN32 AND NOT MINGW)
# PCLConfig.cmake is installed to PCL_ROOT/share/pcl-x.y
  get_filename_component(PCL_ROOT "${PCL_DIR}" PATH)
  get_filename_component(PCL_ROOT "${PCL_ROOT}" PATH)
endif(WIN32 AND NOT MINGW)

# check whether PCLConfig.cmake is found into a PCL installation or in a build tree
if(EXISTS "${PCL_ROOT}/include/pcl-${PCL_VERSION_MAJOR}.${PCL_VERSION_MINOR}/pcl/pcl_config.h")
  # Found a PCL installation
  # pcl_message("Found a PCL installation")
  set(PCL_INCLUDE_DIRS "${PCL_ROOT}/include/pcl-${PCL_VERSION_MAJOR}.${PCL_VERSION_MINOR}")
  set(PCL_LIBRARY_DIRS "${PCL_ROOT}/lib")
  if(EXISTS "${PCL_ROOT}/3rdParty")
    set(PCL_ALL_IN_ONE_INSTALLER ON)
  endif(EXISTS "${PCL_ROOT}/3rdParty")
elseif(EXISTS "${PCL_ROOT}/include/pcl/pcl_config.h")
  # Found a non-standard (likely ANDROID) PCL installation
  # pcl_message("Found a PCL installation")
  set(PCL_INCLUDE_DIRS "${PCL_ROOT}/include")
  set(PCL_LIBRARY_DIRS "${PCL_ROOT}/lib")
  if(EXISTS "${PCL_ROOT}/3rdParty")
    set(PCL_ALL_IN_ONE_INSTALLER ON)
  endif(EXISTS "${PCL_ROOT}/3rdParty")
elseif(EXISTS "${PCL_DIR}/include/pcl/pcl_config.h")
  # Found PCLConfig.cmake in a build tree of PCL
  # pcl_message("PCL found into a build tree.")
  set(PCL_INCLUDE_DIRS "${PCL_DIR}/include") # for pcl_config.h
  set(PCL_LIBRARY_DIRS "${PCL_DIR}/lib")
  set(PCL_SOURCES_TREE "D:/code/3rdparty/src/pcl-pcl-1.8.0")
else(EXISTS "${PCL_ROOT}/include/pcl-${PCL_VERSION_MAJOR}.${PCL_VERSION_MINOR}/pcl/pcl_config.h")
  pcl_report_not_found("PCL can not be found on this machine")  
endif(EXISTS "${PCL_ROOT}/include/pcl-${PCL_VERSION_MAJOR}.${PCL_VERSION_MINOR}/pcl/pcl_config.h")

#set a suffix for debug libraries
set(PCL_DEBUG_SUFFIX "_debug")
set(PCL_RELEASE_SUFFIX "_release")

set(pcl_all_components  common octree io kdtree search sample_consensus filters 2d geometry features ml segmentation visualization surface registration keypoints tracking recognition stereo outofcore people )
list(LENGTH pcl_all_components PCL_NB_COMPONENTS)

#list each component dependencies IN PCL
set(pcl_octree_int_dep common )
set(pcl_io_int_dep common octree )
set(pcl_kdtree_int_dep common )
set(pcl_search_int_dep common kdtree octree )
set(pcl_sample_consensus_int_dep common search )
set(pcl_filters_int_dep common sample_consensus search kdtree octree )
set(pcl_2d_int_dep common io filters )
set(pcl_geometry_int_dep common )
set(pcl_features_int_dep common search kdtree octree filters 2d )
set(pcl_ml_int_dep common )
set(pcl_segmentation_int_dep common geometry search sample_consensus kdtree octree features filters ml )
set(pcl_visualization_int_dep common io kdtree geometry search )
set(pcl_surface_int_dep common search kdtree octree )
set(pcl_registration_int_dep common octree kdtree search sample_consensus features filters )
set(pcl_keypoints_int_dep common search kdtree octree features filters )
set(pcl_tracking_int_dep common search kdtree filters octree )
set(pcl_recognition_int_dep common io search kdtree octree features filters registration sample_consensus ml )
set(pcl_stereo_int_dep common io )
set(pcl_outofcore_int_dep common io filters octree visualization )
set(pcl_people_int_dep common kdtree search features sample_consensus filters io visualization geometry segmentation octree )


#list each component external dependencies (ext means mandatory and opt means optional)
set(pcl_common_ext_dep eigen boost )
set(pcl_kdtree_ext_dep flann )
set(pcl_search_ext_dep flann )
set(pcl_visualization_ext_dep vtk )


set(pcl_io_opt_dep openni openni2 ensenso davidSDK dssdk rssdk pcap png vtk )
set(pcl_2d_opt_dep vtk )
set(pcl_visualization_opt_dep openni openni2 ensenso davidSDK dssdk rssdk )
set(pcl_surface_opt_dep qhull )


set(pcl_header_only_components 2d cuda_common geometry gpu_tracking modeler in_hand_scanner point_cloud_editor cloud_composer optronic_viewer)

include(FindPackageHandleStandardArgs)

#check if user provided a list of components
#if no components at all or full list is given set PCL_FIND_ALL
if(PCL_FIND_COMPONENTS)
  list(LENGTH PCL_FIND_COMPONENTS PCL_FIND_COMPONENTS_LENGTH)
  if(PCL_FIND_COMPONENTS_LENGTH EQUAL PCL_NB_COMPONENTS)
    set(PCL_TO_FIND_COMPONENTS ${pcl_all_components})
    set(PCL_FIND_ALL 1)
  else(PCL_FIND_COMPONENTS_LENGTH EQUAL PCL_NB_COMPONENTS)
    set(PCL_TO_FIND_COMPONENTS ${PCL_FIND_COMPONENTS})    
  endif(PCL_FIND_COMPONENTS_LENGTH EQUAL PCL_NB_COMPONENTS)
else(PCL_FIND_COMPONENTS)
  set(PCL_TO_FIND_COMPONENTS ${pcl_all_components})
  set(PCL_FIND_ALL 1)
endif(PCL_FIND_COMPONENTS)

compute_dependencies(PCL_TO_FIND_COMPONENTS)

# compute external dependencies per component
foreach(component ${PCL_TO_FIND_COMPONENTS})
    foreach(opt ${pcl_${component}_opt_dep})
      find_external_library(${component} ${opt} OPTIONAL)
    endforeach(opt)
    foreach(ext ${pcl_${component}_ext_dep})
      find_external_library(${component} ${ext} REQUIRED)
    endforeach(ext) 
endforeach(component)

foreach(component ${PCL_TO_FIND_COMPONENTS})
  set(pcl_component pcl_${component})
  string(TOUPPER "${component}" COMPONENT)

  pcl_message(STATUS "looking for PCL_${COMPONENT}")

  string(REGEX REPLACE "^cuda_(.*)$" "\\1" cuda_component "${component}")
  string(REGEX REPLACE "^gpu_(.*)$" "\\1" gpu_component "${component}") 
  
  find_path(PCL_${COMPONENT}_INCLUDE_DIR
    NAMES pcl/${component}
          pcl/apps/${component}
          pcl/cuda/${cuda_component} pcl/cuda/${component}
          pcl/gpu/${gpu_component} pcl/gpu/${component}
    HINTS ${PCL_INCLUDE_DIRS}
          "${PCL_SOURCES_TREE}"
    PATH_SUFFIXES
          ${component}/include
          apps/${component}/include
          cuda/${cuda_component}/include 
          gpu/${gpu_component}/include
    DOC "path to ${component} headers"
    NO_DEFAULT_PATH)

  if(PCL_${COMPONENT}_INCLUDE_DIR)
    list(APPEND PCL_${COMPONENT}_INCLUDE_DIRS "${PCL_${COMPONENT}_INCLUDE_DIR}")
  else(PCL_${COMPONENT}_INCLUDE_DIR)
    #pcl_message("No include directory found for pcl_${component}.")
  endif(PCL_${COMPONENT}_INCLUDE_DIR)
  
  # Skip find_library for header only modules
  list(FIND pcl_header_only_components ${component} _is_header_only)
  if(_is_header_only EQUAL -1)
    find_library(PCL_${COMPONENT}_LIBRARY ${pcl_component}${PCL_RELEASE_SUFFIX}
      HINTS ${PCL_LIBRARY_DIRS}
      DOC "path to ${pcl_component} library"
      NO_DEFAULT_PATH)
    get_filename_component(${component}_library_path 
      ${PCL_${COMPONENT}_LIBRARY}
      PATH)

    find_library(PCL_${COMPONENT}_LIBRARY_DEBUG ${pcl_component}${PCL_DEBUG_SUFFIX}
      HINTS ${PCL_LIBRARY_DIRS} 
      DOC "path to ${pcl_component} library debug"
      NO_DEFAULT_PATH)
    if(PCL_${COMPONENT}_LIBRARY_DEBUG)
      get_filename_component(${component}_library_path_debug 
        ${PCL_${COMPONENT}_LIBRARY_DEBUG}
        PATH)
    endif(PCL_${COMPONENT}_LIBRARY_DEBUG)

    # Restrict this to Windows users
    if(NOT PCL_${COMPONENT}_LIBRARY AND WIN32)
      # might be debug only
      set(PCL_${COMPONENT}_LIBRARY ${PCL_${COMPONENT}_LIBRARY_DEBUG})
    endif(NOT PCL_${COMPONENT}_LIBRARY AND WIN32)

    find_package_handle_standard_args(PCL_${COMPONENT} DEFAULT_MSG
      PCL_${COMPONENT}_LIBRARY PCL_${COMPONENT}_INCLUDE_DIR)
  else(_is_header_only EQUAL -1)
    find_package_handle_standard_args(PCL_${COMPONENT} DEFAULT_MSG
      PCL_${COMPONENT}_INCLUDE_DIR)  
  endif(_is_header_only EQUAL -1)
  
  if(PCL_${COMPONENT}_FOUND)
    if(NOT "${PCL_${COMPONENT}_INCLUDE_DIRS}" STREQUAL "")
      list(REMOVE_DUPLICATES PCL_${COMPONENT}_INCLUDE_DIRS)
    endif(NOT "${PCL_${COMPONENT}_INCLUDE_DIRS}" STREQUAL "")
    list(APPEND PCL_INCLUDE_DIRS ${PCL_${COMPONENT}_INCLUDE_DIRS})
    mark_as_advanced(PCL_${COMPONENT}_INCLUDE_DIRS)
    if(_is_header_only EQUAL -1)
      list(APPEND PCL_DEFINITIONS ${PCL_${COMPONENT}_DEFINITIONS})
      list(APPEND PCL_LIBRARY_DIRS ${component_library_path})
      if(PCL_${COMPONENT}_LIBRARY_DEBUG)
        list(APPEND PCL_${COMPONENT}_LIBRARIES optimized ${PCL_${COMPONENT}_LIBRARY} debug ${PCL_${COMPONENT}_LIBRARY_DEBUG})
        list(APPEND PCL_LIBRARY_DIRS ${component_library_path_debug})
      else(PCL_${COMPONENT}_LIBRARY_DEBUG)
        list(APPEND PCL_${COMPONENT}_LIBRARIES ${PCL_${COMPONENT}_LIBRARY})
      endif(PCL_${COMPONENT}_LIBRARY_DEBUG)
      list(APPEND PCL_LIBRARIES ${PCL_${COMPONENT}_LIBRARIES})
      mark_as_advanced(PCL_${COMPONENT}_LIBRARY PCL_${COMPONENT}_LIBRARY_DEBUG)
    endif(_is_header_only EQUAL -1)    
    # Append internal dependencies
    foreach(int_dep ${pcl_${component}_int_dep})
      string(TOUPPER "${int_dep}" INT_DEP)
      if(PCL_${INT_DEP}_FOUND)
        list(APPEND PCL_${COMPONENT}_INCLUDE_DIRS ${PCL_${INT_DEP}_INCLUDE_DIRS})
        if(PCL_${INT_DEP}_LIBRARIES)
          list(APPEND PCL_${COMPONENT}_LIBRARIES "${PCL_${INT_DEP}_LIBRARIES}")
        endif(PCL_${INT_DEP}_LIBRARIES) 
      endif(PCL_${INT_DEP}_FOUND)
    endforeach(int_dep)
  endif(PCL_${COMPONENT}_FOUND)
endforeach(component)

if(NOT "${PCL_INCLUDE_DIRS}" STREQUAL "")
  list(REMOVE_DUPLICATES PCL_INCLUDE_DIRS)
endif(NOT "${PCL_INCLUDE_DIRS}" STREQUAL "")

if(NOT "${PCL_LIBRARY_DIRS}" STREQUAL "")
  list(REMOVE_DUPLICATES PCL_LIBRARY_DIRS)
endif(NOT "${PCL_LIBRARY_DIRS}" STREQUAL "")

if(NOT "${PCL_DEFINITIONS}" STREQUAL "")
  list(REMOVE_DUPLICATES PCL_DEFINITIONS)
endif(NOT "${PCL_DEFINITIONS}" STREQUAL "")

pcl_remove_duplicate_libraries(PCL_LIBRARIES PCL_DEDUP_LIBRARIES)
set(PCL_LIBRARIES ${PCL_DEDUP_LIBRARIES})
# Add 3rd party libraries, as user code might include our .HPP implementations
list(APPEND PCL_LIBRARIES ${BOOST_LIBRARIES} ${QHULL_LIBRARIES} ${OPENNI_LIBRARIES} ${OPENNI2_LIBRARIES} ${ENSENSO_LIBRARIES} ${davidSDK_LIBRARIES} ${DSSDK_LIBRARIES} ${RSSDK_LIBRARIES} ${FLANN_LIBRARIES} ${VTK_LIBRARIES})

find_package_handle_standard_args(PCL DEFAULT_MSG PCL_LIBRARIES PCL_INCLUDE_DIRS)
mark_as_advanced(PCL_LIBRARIES PCL_INCLUDE_DIRS PCL_LIBRARY_DIRS)

