from conans import ConanFile, CMake, tools


class LibuwscConan(ConanFile):
    name = "libuwsc"
    version = "3.3.5"
    author = ""
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False], "with_tests": [True, False]}
    default_options = {"shared": False, "fPIC": True, "with_tests": False}
    exports_sources = ("include/*", "CMakeLists.txt", "src/*")
    generators = 'cmake_find_package'

    def requirements(self):
        self.requires("libev/4.33")
        self.requires("openssl/1.1.1w")

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        self.copy("*.h", dst="include", src="include")
        self.copy("*.h", dst="include", src="src/buffer")
        self.copy("ssl.h", dst="include", src="src/ssl")
        self.copy("*hello.lib", dst="lib", keep_path=False)
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.dylib", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)

    def package_info(self):
        self.cpp_info.libs = ["uwsc"]
