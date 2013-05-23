#
# Dependencies
#
find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED
	libsoup-2.4
	libxml-2.0
	libnotify
	granite
	gee-1.0
	
)

#add_definitions(${DEPS_CFLAGS})
#link_libraries(${DEPS_LIBRARIES})
#link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.14.2" MINIMUM)
include(ValaPrecompile)

vala_precompile(VALA_C
    abstract.vala
    backend-xml.vala
#	database.vala
#   interface.vala
    model.vala
    serializer.vala
    service.vala
	settings.vala
PACKAGES
    granite
	libnotify
	libsoup-2.4
	libxml-2.0
    gee-1.0
	sqlheavy-0.2
#CUSTOM_VAPIS
#    ../../vapi/config.vapi
OPTIONS
    --thread
    -g
)

# Verbose GCC
#add_definitions(${CFLAGS} -Wall -Winit-self -Wwrite-strings -Wunreachable-code -Wstrict-prototypes )
add_executable(feedler-service ${VALA_C})

install(TARGETS feedler-service RUNTIME DESTINATION bin)

#
# GSettings Schema
#
#include(GSettings)
#add_schema("org.elementary.feedler.gschema.xml")

