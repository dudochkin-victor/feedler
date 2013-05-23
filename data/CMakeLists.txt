# Desktop
configure_file(feedler.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/feedler.desktop)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/feedler.desktop DESTINATION share/applications)

# Service
configure_file(feedler.service.cmake ${CMAKE_CURRENT_BINARY_DIR}/feedler.service)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/feedler.service DESTINATION share/dbus-1/services/)

# Indicator
configure_file(feedler.cmake ${CMAKE_CURRENT_BINARY_DIR}/feedler)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/feedler DESTINATION share/indicators/messages/applications)

#Icons
install (DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/icons DESTINATION share/feedler)

# GSchema
include(GSettings)
add_schema("org.elementary.feedler.gschema.xml")
