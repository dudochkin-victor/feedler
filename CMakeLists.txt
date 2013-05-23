cmake_minimum_required (VERSION 2.8)
project (feedler)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)

#
# Base bits
#
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/feedler")
set (GETTEXT_PACKAGE "feedler")
set (RELEASE_NAME "Growing up.")
set (VERSION "0.2")
set (VERSION_INFO "Beta")

#
# config.h
#
configure_file (${CMAKE_SOURCE_DIR}/config.h.cmake ${CMAKE_BINARY_DIR}/config.h)
add_definitions(-include config.h)

#
# i18n
#
find_package (Gettext REQUIRED)

add_custom_command (OUTPUT ${CMAKE_SOURCE_DIR}/po/feedler.pot
	COMMAND xgettext -c --files-from ${CMAKE_SOURCE_DIR}/po/POTFILES.in --keyword=_ -o ${CMAKE_SOURCE_DIR}/po/feedler.pot --no-wrap --no-location
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

if (${GETTEXT_FOUND} STREQUAL "TRUE")
	set (HAVE_GETTEXT true)
	file (GLOB _translations ${CMAKE_SOURCE_DIR}/po/*.po)
	GETTEXT_CREATE_TRANSLATIONS (${CMAKE_SOURCE_DIR}/po/${PROJECT_NAME}.pot
		ALL ${_translations})
endif (${GETTEXT_FOUND} STREQUAL "TRUE")

#
# Dependencies
#
find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED
	webkitgtk-3.0
	gtk+-3.0
	sqlheavy-0.2
	libsoup-2.4
	libxml-2.0
	libnotify
	unity
	granite
#	gee-1.0
	indicate-0.7
)

add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.16.0" MINIMUM)
include(ValaPrecompile)

vala_precompile(VALA_C
	src/desktop-launcher.vala
	src/database.vala
	src/dock.vala
	src/feedler.vala
	src/icons.vala
	src/indicator.vala
	src/history.vala
	src/manager.vala
	src/settings.vala
	src/window.vala
	src/ui/contractor.vala
	src/ui/folder.vala
	src/ui/infobar.vala
	src/ui/layout.vala
	src/ui/menu.vala
	src/ui/preferences.vala
	src/ui/sidebar.vala
	src/ui/sidebar-cell.vala
	src/ui/statusbar.vala
	src/ui/subscription.vala
	src/ui/toolbar.vala
	src/ui/view.vala
	src/ui/view-cell.vala
	src/ui/view-list.vala
	src/ui/view-web.vala
    src/service/interface.vala
    src/service/model.vala
    src/service/serializer.vala
PACKAGES
	gtk+-3.0
    granite
	#libnotify
	unity
	libsoup-2.4
	libxml-2.0
	sqlheavy-0.2
#    gee-1.0
	DbusmenuGtk3-0.4
	Dbusmenu-0.4
CUSTOM_VAPIS
    vapi/config.vapi
	vapi/webkitgtk-3.0.vapi
	vapi/Indicate-0.7.vapi
OPTIONS
    --thread
    -g
	--target-glib=2.32
)


add_executable(feedler ${VALA_C})
install(TARGETS feedler RUNTIME DESTINATION bin)
add_subdirectory (src/service)
add_subdirectory (data)

MESSAGE(STATUS "<<< Gentoo configuration >>>
Build type      ${CMAKE_BUILD_TYPE}
Install path    ${CMAKE_INSTALL_PREFIX}
Compiler flags:
C               ${CMAKE_C_FLAGS}
C++             ${CMAKE_CXX_FLAGS}
Linker flags:
Executable      ${CMAKE_EXE_LINKER_FLAGS}
Module          ${CMAKE_MODULE_LINKER_FLAGS}
Shared          ${CMAKE_SHARED_LINKER_FLAGS}\n")
