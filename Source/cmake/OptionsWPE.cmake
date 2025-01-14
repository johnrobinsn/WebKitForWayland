include(GNUInstallDirs)

set(PROJECT_VERSION_MAJOR 0)
set(PROJECT_VERSION_MINOR 0)
set(PROJECT_VERSION_PATCH 1)
set(PROJECT_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})

set(WPE_DIR "${CMAKE_SOURCE_DIR}/Source/WPE/Headers")

WEBKIT_OPTION_BEGIN()
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_3D_TRANSFORMS PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_ACCELERATED_2D_CANVAS PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_CSS_IMAGE_SET PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_CSS_REGIONS PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_CSS_SELECTORS_LEVEL4 PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_ENCRYPTED_MEDIA PUBLIC OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_ENCRYPTED_MEDIA_V2 PUBLIC OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_INSPECTOR PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_MEDIA_CONTROLS_SCRIPT PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_NETSCAPE_PLUGIN_API PRIVATE OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_NETWORK_PROCESS PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_PICTURE_SIZES PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_REQUEST_ANIMATION_FRAME PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_SHARED_WORKERS PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_TEMPLATE_ELEMENT PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_TOUCH_EVENTS PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_VIDEO PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_VIDEO_TRACK PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_VIEW_MODE_CSS_MEDIA PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_WEB_AUDIO PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_WEBGL PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_WEB_TIMING PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_XHR_TIMEOUT PUBLIC ON)
WEBKIT_OPTION_END()

if (ENABLE_DXDRM)
    add_definitions(-DWTF_USE_DXDRM=1)
endif ()

set(ENABLE_WEBCORE ON)
set(ENABLE_WEBKIT OFF)
set(ENABLE_WEBKIT2 ON)
set(ENABLE_API_TESTS OFF)

if (DEVELOPER_MODE)
    set(ENABLE_TOOLS ON)
else ()
    set(ENABLE_TOOLS OFF)
endif ()

set(WTF_LIBRARY_TYPE STATIC)
set(JavaScriptCore_LIBRARY_TYPE STATIC)
set(WebCore_LIBRARY_TYPE STATIC)
set(WebKit2_OUTPUT_NAME WPEWebKit)
set(WebKit2_WebProcess_OUTPUT_NAME WPEWebProcess)
set(WebKit2_NetworkProcess_OUTPUT_NAME WPENetworkProcess)

find_package(ICU REQUIRED)
find_package(Threads REQUIRED)
find_package(ZLIB REQUIRED)
find_package(GLIB 2.40.0 REQUIRED COMPONENTS gio gobject gthread gmodule)

find_package(Cairo 1.10.2 REQUIRED)
find_package(CairoGL 1.10.2 REQUIRED COMPONENTS cairo-egl)
find_package(Fontconfig 2.8.0 REQUIRED)
find_package(Freetype2 2.4.2 REQUIRED)
find_package(HarfBuzz 0.9.2 REQUIRED)
find_package(JPEG REQUIRED)
find_package(LibSoup 2.40.3 REQUIRED)
find_package(LibXml2 2.8.0 REQUIRED)
find_package(LibXslt 1.1.7 REQUIRED)
find_package(PNG REQUIRED)
find_package(Sqlite REQUIRED)
find_package(Wayland 1.6.0 REQUIRED)
find_package(WebP REQUIRED)

find_package(OpenGLES2 REQUIRED)
find_package(EGL REQUIRED)
find_package(WaylandEGL REQUIRED)

find_package(Athol 0.1)
if (ATHOL_FOUND)
    set(ENABLE_ATHOL_SHELL ON)
else ()
    find_package(Weston 1.6.0 REQUIRED)
    if (WESTON_FOUND)
        set(ENABLE_WESTON_SHELL ON)
    endif ()
endif ()

if (ENABLE_SUBTLE_CRYPTO)
    find_package(GnuTLS 3.0.0)
    if (NOT GNUTLS_FOUND)
        message(FATAL_ERROR "GnuTLS is needed for ENABLE_SUBTLE_CRYPTO")
    endif ()
endif ()

if (ENABLE_VIDEO OR ENABLE_WEB_AUDIO)
    set(GSTREAMER_COMPONENTS app audio pbutils)
    SET_AND_EXPOSE_TO_BUILD(USE_GSTREAMER TRUE)
    if (ENABLE_VIDEO)
        list(APPEND GSTREAMER_COMPONENTS video tag)
    endif ()

    if (ENABLE_WEB_AUDIO)
        list(APPEND GSTREAMER_COMPONENTS fft)
        SET_AND_EXPOSE_TO_BUILD(USE_WEBAUDIO_GSTREAMER TRUE)
    endif ()

    find_package(GStreamer 1.4.2 REQUIRED COMPONENTS ${GSTREAMER_COMPONENTS})

    # FIXME: What about MPEGTS support? USE_GSTREAMER_MPEGTS?
endif ()

add_definitions(-DBUILDING_WPE__=1)
add_definitions(-DDATA_DIR="${CMAKE_INSTALL_DATADIR}")

set(USE_UDIS86 1)

SET_AND_EXPOSE_TO_BUILD(USE_OPENGL TRUE)
SET_AND_EXPOSE_TO_BUILD(USE_OPENGL_ES_2 TRUE)

SET_AND_EXPOSE_TO_BUILD(ENABLE_GRAPHICS_CONTEXT_3D TRUE)

SET_AND_EXPOSE_TO_BUILD(USE_TEXTURE_MAPPER TRUE)
SET_AND_EXPOSE_TO_BUILD(USE_TEXTURE_MAPPER_GL TRUE)
if (ENABLE_THREADED_COMPOSITOR)
    SET_AND_EXPOSE_TO_BUILD(USE_TILED_BACKING_STORE TRUE)
    SET_AND_EXPOSE_TO_BUILD(USE_COORDINATED_GRAPHICS TRUE)
    SET_AND_EXPOSE_TO_BUILD(USE_COORDINATED_GRAPHICS_THREADED TRUE)
endif ()

SET_AND_EXPOSE_TO_BUILD(USE_EGL TRUE)
SET_AND_EXPOSE_TO_BUILD(WTF_PLATFORM_WAYLAND TRUE)

set(FORWARDING_HEADERS_DIR ${DERIVED_SOURCES_DIR}/ForwardingHeaders)

# Build with -fvisibility=hidden to reduce the size of the shared library.
# Not to be used when building the WebKitTestRunner library.
if (NOT DEVELOPER_MODE)
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -fvisibility=hidden")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fvisibility=hidden -fvisibility-inlines-hidden")
endif ()
