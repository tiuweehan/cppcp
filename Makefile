MAKEFLAGS += -s

# If the first argument is "run" or "new"...
ifneq (,$(filter $(firstword $(MAKECMDGOALS)),run new reset))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

# C++ compiler
CC := /usr/local/bin/g++-10

# C++ version
CPPVERSION := 11

# Sources to include
SOURCES := kattis kickstart leetcode scratch adventofcode

# Sources to use solution.cpp
SOLUTIONCPP := kickstart leetcode adventofcode

.PHONY: run new reset cmake

RUN_HEADERS := -DREAD_STDIN_FROM_FILE -DINCLUDE_HEADERS -DINCLUDE_MAIN -DENABLE_DEBUG

run:
	@$(CC) $(RUN_ARGS)/*.cpp -o $(RUN_ARGS)/main.out $(RUN_HEADERS);
	@for i in $(RUN_ARGS)/*.in; do \
  		echo; \
		echo ===============================; \
		echo $$i; \
		echo ===============================; \
		$(RUN_ARGS)/main.out < $$i; \
	done
	@rm -rf $(RUN_ARGS)/main.out;

new:
	@if :; then \
		trimmed_path=$$(echo $(RUN_ARGS) | sed 's/\/*$$//g'); \
		base=$$(echo $$trimmed_path | cut -d "/" -f1); \
		new_file="$$(echo $$trimmed_path | rev | cut -d '/' -f1 | rev).cpp"; \
		solutioncpp=$$(echo $(SOLUTIONCPP) | sed 's/ /|/g'); \
		if echo $$base | grep -Eq "^($$solutioncpp)$$"; then \
		  	new_file="solution.cpp"; \
		fi; \
		mkdir -p $$trimmed_path; \
		cp -n $$base/template.cpp $$trimmed_path/$$new_file; \
		for i in $$(seq 1 3); do \
			touch $$trimmed_path/$$i.in; \
		done; \
	fi;
	@make cmake;

# Overrides existing files
reset:
	@if :; then \
		trimmed_path=$$(echo $(RUN_ARGS) | sed 's/\/*$$//g'); \
		base=$$(echo $$trimmed_path | cut -d "/" -f1); \
		new_file="$$(echo $$trimmed_path | rev | cut -d '/' -f1 | rev).cpp"; \
		solutioncpp=$$(echo $(SOLUTIONCPP) | sed 's/ /|/g'); \
		if echo $$base | grep -Eq "^($$solutioncpp)$$"; then \
		  	new_file="solution.cpp"; \
		fi; \
		mkdir -p $$trimmed_path; \
		cp $$base/template.cpp $$trimmed_path/$$new_file; \
		for i in $$(seq 1 3); do \
			touch $$trimmed_path/$$i.in; \
		done; \
	fi;
	@make cmake;

cmake:
	@echo 'cmake_minimum_required(VERSION 3.16)' > CMakeLists.txt
	@echo 'project(cppcp)' >> CMakeLists.txt
	@echo >> CMakeLists.txt
	@echo 'set(CMAKE_CXX_STANDARD $(CPPVERSION))' >> CMakeLists.txt
	@echo 'set(CMAKE_CXX_COMPILER $(CC))' >> CMakeLists.txt
	@echo >> CMakeLists.txt
	@echo 'set(GCC_COVERAGE_COMPILE_FLAGS "$(RUN_HEADERS)")' >> CMakeLists.txt
	@echo 'add_definitions($${GCC_COVERAGE_COMPILE_FLAGS})' >> CMakeLists.txt
	@echo >> CMakeLists.txt
	@for source in $(SOURCES); do \
		for file in $$(find $$source -type f -name "*.cpp"); do \
			folder=$$(echo $$file | rev | cut -d '/' -f 2- | rev); \
			executable="$$(echo $$file | sed -e "s/\//\-/g; s/\.cpp//").out"; \
			echo "add_executable($$executable $$file)" >> CMakeLists.txt; \
			echo "set_target_properties($$executable PROPERTIES RUNTIME_OUTPUT_DIRECTORY "'$${PROJECT_SOURCE_DIR}'"/$$folder)" >> CMakeLists.txt; \
		done \
	done
