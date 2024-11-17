ifeq ($(shell uname -s),Linux)
	CONAN_UPDATE_COMMAND := conan profile update settings.compiler.libcxx=libstdc++11 default
endif

PACKAGE_NAME = $(shell conan inspect . --attribute name | awk '{print $$2}')
PACKAGE_VERSION = $(shell conan inspect . --attribute version | awk '{print $$2}')

.PHONEY: debug release clean conan conan-release conan-clean

debug:
	$(CONAN_UPDATE_COMMAND)
	mkdir -p build && cd build; \
	conan install --build missing -s build_type=Debug ..; \
	cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_VERBOSE_MAKEFILE=ON -DBUILD_TESTS=ON ..; \
	make -j2

release:
	$(CONAN_UPDATE_COMMAND)
	mkdir -p build && cd build; \
	conan install --build missing -s build_type=Release ..; \
	cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=ON -DBUILD_TESTS=ON ..; \
	make -j2

clean:
	rm -rf build

conan: conan-clean
	# build_type: Debug Release RelWithDebInfo MinSizeRel
	conan create -s build_type=Debug .

conan-release: conan-clean
	conan create -s build_type=Release .

conan-clean:
	conan remove -f $(PACKAGE_NAME)/$(PACKAGE_VERSION)
