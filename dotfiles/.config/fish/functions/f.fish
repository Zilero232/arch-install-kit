function f --description 'Find files under the current directory whose name contains <text>'
    if test (count $argv) -ne 1
        echo "Usage: f <text>"
        return 1
    end

    find . -name "*$argv[1]*"
end
