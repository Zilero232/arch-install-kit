function mkcd --description 'Create a directory and cd into it'
    mkdir -p $argv[1]; and cd $argv[1]
end
