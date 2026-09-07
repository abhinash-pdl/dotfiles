function arch --description 'Arch Linux helper commands'
    switch "$argv[1]"
        case update
            sudo pacman -Syu

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
                paru -S $packages
            else
                sudo pacman -S  $packages
            end

        case remove
            if test (count $argv) -lt 2
                echo "Usage: arch remove <package...>"
                return 1
            end
            sudo pacman -Rns $argv[2..-1]

        case search
            if test (count $argv) -lt 2
                echo "Usage: arch search <term>"
                return 1
            end
            pacman -Ss $argv[2]
            echo "--- AUR (paru) ---"
            paru -Ss $argv[2] 2>/dev/null

        case info
            if test (count $argv) -lt 2
                echo "Usage: arch info <package>"
                return 1
            end
            pacman -Qi $argv[2] 2>/dev/null; or pacman -Si $argv[2]

        case deps
            # reverse dependency tree — what depends on this package
            if test (count $argv) -lt 2
                echo "Usage: arch deps <package>"
                return 1
            end
            pactree -r $argv[2]

        case size
            # top N installed packages by size, default 20
            set -l n 20
            if test (count $argv) -ge 2
                set n $argv[2]
            end
            pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -rh | head -n $n

        case clean
            # -Sc clears uninstalled/old cached packages; -Scc for everything
            sudo pacman -Sc

        case clean-all
            sudo pacman -Scc

        case orphan
            set -l orphans (pacman -Qtdq)
            if test (count $orphans) -gt 0
                sudo pacman -Rns $orphans
            else
                echo "No orphaned packages found."
            end

        case explicit
            # list explicitly installed packages — useful for auditing after DB issues
            pacman -Qe

        case asdeps
            if test (count $argv) -lt 2
                echo "Usage: arch asdeps <package...>"
                return 1
            end
            sudo pacman -D --asdeps $argv[2..-1]

        case asexplicit
            if test (count $argv) -lt 2
                echo "Usage: arch asexplicit <package...>"
                return 1
            end
            sudo pacman -D --asexplicit $argv[2..-1]

        case mirror
            # refresh mirrorlist ranked by speed, needs reflector installed
            sudo reflector --country Nepal,India,Singapore --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
            and echo "Mirrorlist updated."

        case history
            # recent pacman transactions
            set -l n 30
            if test (count $argv) -ge 2
                set n $argv[2]
            end
            grep -E "installed|removed|upgraded" /var/log/pacman.log | tail -n $n

        case check
            # verify installed files match package db
            sudo pacman -Qkk 2>&1 | grep -v "0 missing files"

        case '*'
            echo "Usage:"
            echo "  arch update              - full system upgrade"
            echo "  arch install <pkg...>    - install (falls back to paru for AUR)"
            echo "  arch remove <pkg...>     - remove package + unneeded deps"
            echo "  arch search <term>       - search repos + AUR"
            echo "  arch info <pkg>          - show package info"
            echo "  arch deps <pkg>          - show reverse dependency tree"
            echo "  arch size [n]            - top n packages by installed size"
            echo "  arch clean               - clear uninstalled package cache"
            echo "  arch clean-all           - clear entire package cache"
            echo "  arch orphan              - remove orphaned packages"
            echo "  arch explicit            - list explicitly installed packages"
            echo "  arch asdeps <pkg...>     - mark package as dependency"
            echo "  arch asexplicit <pkg...> - mark package as explicit"
            echo "  arch mirror              - refresh mirrorlist (needs reflector)"
            echo "  arch history [n]         - recent pacman transactions"
            echo "  arch check               - verify installed files vs db"
    end
end
