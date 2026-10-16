function f --description 'Find files under the current directory whose name contains <text>'
    find . -name "*$argv[1]*"
end
