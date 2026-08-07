function arch --description 'Arch Linux helper commands'
    switch "$argv[1]"
        case update
            sudo pacman -Syyu --overwrite "*"
            
        case install
            if test (count $argv) -lt 2
                echo "Usage: arch install <package...>"
                return 1
            end
            
            set -l packages $argv[2..-1]
            set -l use_paru 0
            
            for pkg in $packages
                if not pacman -Si $pkg >/dev/null 2>&1
                    set use_paru 1
                    break
                end
            end
            
            if test $use_paru -eq 1
                echo "Falling back to paru..."
                paru -S --overwrite "*" $packages
            else
                sudo pacman -S --overwrite "*" $packages
            end
            
        case clean
            sudo pacman -Sc
            
        case orphan
            set -l orphans (pacman -Qtdq)
            if test (count $orphans) -gt 0
                sudo pacman -Rns $orphans
            else
                echo "No orphaned packages found."
            end
            
        case '*'
            echo "Usage:"
            echo "  arch update"
            echo "  arch install <package...>"
            echo "  arch clean"
            echo "  arch orphan"
    end
end
