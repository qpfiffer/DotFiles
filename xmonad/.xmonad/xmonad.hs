import XMonad

main = do
    xmonad $ defaultConfig
        { terminal      = "urxvtc"
        , borderWidth   = 1 
        , workspaces    = [ "www", "term", "dev", "irc", "misc" ]
        }
