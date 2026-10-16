function pack --description 'Pack <directory> into <directory>.tar.gz'
    if test (count $argv) -ne 1
        echo "Usage: pack <directory>"
        return 1
    end

    tar -czf $argv[1].tar.gz $argv[1]
end
