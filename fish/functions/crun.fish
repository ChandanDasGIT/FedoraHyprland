function crun
    # Check if a file was provided
    if test (count $argv) -eq 0
        echo "Usage: crun <filename.cpp> [extra flags...]"
        return 1
    end

    set -l file $argv[1]
    set -l name (string replace -r '\.cpp$' '' $file)
    set -l user_flags $argv[2..]
    set -l auto_flags

    # 1. If CMakeLists.txt exists, prefer cmake workflow
    if test -f CMakeLists.txt
        echo "* Detected CMakeLists.txt: Building via CMake *"
        cmake -B build -S . && cmake --build build
        if test $status -eq 0
            # Look for the binary in common build locations
            if test -f "build/$name"
                echo "----------------------------------------"
                echo "* Running ./build/$name *"
                echo "----------------------------------------"
                ./build/$name
            else if test -f "build/ChaosNotes"
                ./build/ChaosNotes
            end
        end
        return
    end

    # 2. Check for Qt includes in the source files
    set -l has_qt 0
    if grep -qE '#include <(Q[A-Z]|Qt)' $file 2>/dev/null
        set has_qt 1
    end

    # 3. Resolve Qt pkg-config flags if Qt is used
    if test $has_qt -eq 1
        echo "* Qt headers detected. Resolving compiler flags... *"
        
        # Test for Qt6 first, then Qt5
        set -l qt_ver ""
        if pkg-config --exists Qt6Core
            set qt_ver "Qt6"
        else if pkg-config --exists Qt5Core
            set qt_ver "Qt5"
        end

        if test -n "$qt_ver"
            # Gather all commonly used modules that are installed
            set -l qt_modules
            for mod in Core Gui Widgets Qml Quick QuickControls2
                if pkg-config --exists "$qt_ver$mod"
                    set -a qt_modules "$qt_ver$mod"
                end
            end

            # pkg-config flags + -fPIC required by Qt
            set auto_flags -fPIC (pkg-config --cflags --libs $qt_modules)
        else
            echo "⚠️ Warning: Qt headers detected, but no Qt pkg-config files found."
        end
    end

    # 4. Check single vs multi-file compilation
    set -l all_cpps *.cpp
    if test (count $all_cpps) -gt 1
        echo "* Executing task: Build multi-file project with g++ *"
        echo "> g++ -std=c++20 -Wall *.cpp -o $name $auto_flags $user_flags"
        g++ -std=c++20 -Wall *.cpp -o $name $auto_flags $user_flags
    else
        echo "* Executing task: Build single file with g++ *"
        echo "> g++ -std=c++20 -Wall $file -o $name $auto_flags $user_flags"
        g++ -std=c++20 -Wall $file -o $name $auto_flags $user_flags
    end

    # 5. Execute on success
    if test $status -eq 0
        echo "----------------------------------------"
        echo "* Task succeeded. Running ./$name *"
        echo "----------------------------------------"
        ./$name
    else
        echo "----------------------------------------"
        echo "❌ [Task failed: Build errors detected]"
        echo "----------------------------------------"
        return 1
    end
end
