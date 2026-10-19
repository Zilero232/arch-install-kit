function pack --description 'Pack <directory> into <directory>.tar.gz'
    if test (count $argv) -ne 1
        echo "Usage: pack <directory>"
        return 1
    end

    # Tab completion adds a trailing slash, which would put the archive inside the folder
    set -l dir (string trim --right --chars / -- $argv[1])
    tar -czf $dir.tar.gz $dir
end
