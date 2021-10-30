
-- Taurus Omar
-- TaurusOmar.com
-- @TaurusOmar_
--
--
import XMonad
import XMonad.Config.Desktop
import Data.Monoid
import Data.Maybe (isJust)
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

    -- Utilities
import XMonad.Util.Loggers
import XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (safeSpawn, unsafeSpawn, runInTerm, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.Dmenu

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isDialog, doCenterFloat, isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory


    -- Actions
import XMonad.Actions.Minimize (minimizeWindow)
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.CopyWindow (kill1, copyToAll, killAllOtherCopies, runOrCopy)
import XMonad.Actions.WindowGo (runOrRaise, raiseMaybe)
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen, shiftNextScreen, shiftPrevScreen, swapNextScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.DynamicWorkspaces (addWorkspacePrompt, removeEmptyWorkspace)
import XMonad.Actions.MouseResize
import qualified XMonad.Actions.ConstrainedResize as Sqr
import XMonad.Actions.WindowMenu
import XMonad.Actions.UpdatePointer


    -- Prompt
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Prompt.Ssh
import XMonad.Prompt.XMonad
import Control.Arrow (first)
import XMonad.Prompt.ConfirmPrompt




    -- Data
import Data.Char (isSpace)

    -- Layouts modifiers
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Renamed (renamed, Rename(CutWordsLeft, Replace))
import XMonad.Layout.WorkspaceDir
import XMonad.Layout.Spacing (spacing)
import XMonad.Layout.NoBorders
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.Reflect (reflectVert, reflectHoriz, REFLECTX(..), REFLECTY(..))
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), Toggle(..), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))

    -- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.OneBig
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ResizableTile
import XMonad.Layout.ZoomRow (zoomRow, zoomIn, zoomOut, zoomReset, ZoomMessage(ZoomFullToggle))
import XMonad.Layout.IM (withIM, Property(Role))
import XMonad.Layout.Accordion
import XMonad.Layout.Cross
import XMonad.Layout.ShowWName


 -- Prompts
import XMonad.Prompt (defaultXPConfig, XPConfig(..), XPPosition(Top), Direction1D(..))
import XMonad.Prompt.Man
import XMonad.Prompt.AppendFile


myFont          = "xft:Ubuntu:weight=bold:pixelsize=11:antialias=true:hinting=true"
myModMask       = mod4Mask               -- Setear la tecla maestra / por defecto windows key
myTerminal      = "alacritty"       -- Terminal por defecto
myBrowser       = "brave-browser"        -- Browser por defecto
myTextEditor    = "vim"                 -- Editor de texto por defecto
myBorderWidth   = 1                      -- Setear el tamano del borde
windowCount     = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

main = do
-- xmproc0 <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobarrc0" --Descomentar si usas xmobar
 -- xmproc1 <- spawnPipe "xmobar -x 1 ~/.config/xmobar/xmobarrc0" --Descomentar para activar segunda pantalla
    xmonad $ ewmh desktopConfig
        { manageHook = ( isFullscreen --> doFullFloat )   <+> myManageHook <+> manageHook desktopConfig <+> manageDocks
        , logHook = dynamicLogWithPP xmobarPP
                        { ppCurrent         = xmobarColor "#8EC07C" "" . wrap "/" "/"
                        , ppVisible         = xmobarColor "#D79921" ""
                        , ppHidden          = xmobarColor "#D79921" "" . wrap "°" ""
                        , ppHiddenNoWindows = xmobarColor "#a89984" ""
                        , ppTitle           = xmobarColor "#FBF1C7" "" . shorten 60
                        , ppSep             =  "<fc=#CC241D> => </fc>"
                        , ppUrgent          = xmobarColor "#cc241d" "" . wrap "!" "!"
                        , ppExtras          = [windowCount]
                        , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        } >>  updatePointer (0.5, 0.5) (0, 0)

        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = "#212121"
        , focusedBorderColor = "#98971a"
        } `additionalKeysP`         myKeys

-- Para mostrar los nombred de cada workspace
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Ubuntu:bold:size=55"
    , swn_fade              = 1.0
    , swn_bgcolor           = "#212121"
    , swn_color             = "#98971a"
    }


------------------------------------------------------------
---                  AUTOSTART                           ---
------------------------------------------------------------
    --
myStartupHook = do
          spawnOnce "flameshot &"
          setWMName "XMonad"
          spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x282c34  --height 22 &"
          setWMName "LG3D"
          spawn "$HOME/.xmonad/scripts/autostart.sh"
          spawnOnce "nvidia-settings -a [gpu:0]/GPUPowerMizerMode=1"


---------------------------------------------------
---        CONFIGURACIONES DEL GRID             ---
---------------------------------------------------

--- Color del Grid
myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                  (0x28,0x28,0x28)
                  (0x28,0x28,0x28)
                  (0x28,0x28,0x28)
                  (0xd5,0xc4,0xa1)
                  (0xff,0xff,0xff)

-- Tamano del grid
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 30
    , gs_cellwidth    = 200
    , gs_cellpadding  = 8
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = defaultGSConfig



----------------------------------------------------------------------------------
--                          XPROMPT Configuraciones                            ---
----------------------------------------------------------------------------------

omarXPConfig :: XPConfig
omarXPConfig = def
      { font                = myFont
      , bgColor             = "#212121"
      , fgColor             = "#d4be98"
      , bgHLight            = "#689d6a"
      , fgHLight            = "#090c10"
      , borderColor         = "#DC9656"
      , promptBorderWidth   = 0
      , position            = Top
--    , position            = CenteredAt { xpCenterY = 0.3, xpWidth = 0.3 }
      , height              = 20
      , historySize         = 256
      , historyFilter       = id
      , defaultText         = []
      , autoComplete        = Just 10000
      , showCompletionOnTab = False
      --, searchPredicate     = isPrefixOf
      --, searchPredicate     = fuzzyMatch
      , alwaysHighlight     = True
      , maxComplRows        = Nothing
      }

omarXPConfig' :: XPConfig
omarXPConfig' = omarXPConfig
      { autoComplete        = Nothing
      }
----------------------------------------------------------------------------------
--                  Funcion Buscar Ruta o Archivo                              ---
----------------------------------------------------------------------------------
    --
whereis :: XPConfig -> String -> X ()
whereis c ans =
    inputPrompt c (trim ans) ?+ \input ->
        liftIO(runProcessWithInput "whereis" [input] "") >>= whereis c
    where
        trim = f . f
            where f = reverse . dropWhile isSpace
----------------------------------------------------------------------------------
--                  Funcion Promt confirmar salida de Xmonad                   ---
----------------------------------------------------------------------------------
    --
exitPrompt :: X ()
exitPrompt = confirmPrompt omarXPConfig "Quit XMonad?" $ io exitSuccess

----------------------------------------------------------------------------------
---                       COMBINACION DE TECLAS                                ---
----------------------------------------------------------------------------------

myKeys =
    -- configuraciones Xmonad
        [ ("M-C-r", spawn "xmonad --recompile")                             -- Recompilar xmonad
        , ("M-S-r", spawn "xmonad --restart")                               -- Restar xmonad
        , ("M-S-e", exitPrompt)                                             -- Salir de xmonad

    -- Acciones sobre las ventanas
        , ("M-q", kill1)                                                    -- Cerrar ventana
        , ("M-S-q", killAll)                                                -- Cerrar todas las ventanas
        , ("M-<Delete>", withFocused $ windows . W.sink)                    -- Restaurar ventna flotante


    -- Menu Browers
        , (("M-C-o"), spawnSelected'
          [ ("Brave", "brave")
          , ("Qutebrowser", "qutebrowser")
          , ("Tor", "exec-in-shell ~/tools/tor/./Browser/start-tor-browser --detach")
          , ("UfoVim", "alacritty -e /home/omar/.local/bin/ufovim")
          , ("File Manager", "alacritty -e /home/omar/.local/bin/ufovim /home/omar/")
          , ("PcmanFM", "pcmanfm")
          , ("Telegram", "telegram-desktop")
          , ("Discord", "discord")
          , ("Gimp", "gimp")
          , ("Obs", "alacritty -e sudo obs")
          , ("Kdenlive", "/home/omar/otros/kdenlive-21.08.2-x86_64.appimage")
          , ("BurpSuite", "java -javaagent:/home/omar/tools/web/BurpSuite/BurpSuiteLoader_v2020.11.3.jar -noverify -jar /home/omar/tools/web/BurpSuite/burpsuite_pro_v2021.9.jar")
          ])
    

    -- Menu URLs
          , (("M-C-p"), spawnSelected'
          [ ("0day", "brave 0day.today")
          , ("Explot DB", "brave https://exploit-db.com")
          , ("PacketStorm", "brave packetstormsecurity.com ")
          , ("GTFOBins", "brave gtfobins.github.io")
          , ("TaurusOmar", "brave https://taurusomar.com")
          , ("GitHub ", "brave github.com/taurusomar")
          ])


    -- Run Prompt
        , ("M-C-<Return>", shellPrompt omarXPConfig)                                    -- Abrir shellPrompt
        , ("M-C-w", whereis omarXPConfig "whereis")                                     -- Buscar Path
        , ("M-C-s", sshPrompt omarXPConfig)                                             -- Conexion SSH
        , ("M-C-g", goToSelected $ mygridConfig myColorizer)                            -- Ir a la ventana
        , ("M-C-b", bringSelected $ mygridConfig myColorizer)                           -- Traer Ventana al espacion de trabajo
        , ("M-C-h", manPrompt omarXPConfig)                                             -- Comando man 
        , ("M-C-n", appendFilePrompt omarXPConfig "/home/omar/notas/notas.txt")         -- Agregar notas rapidas
        , ("M-C-a", windowMenu)


    -- Navegacion de ventanas
        , ("M-m", windows W.focusMaster)                                                -- Focus a la princial ventana
        , ("M-<Down>", windows W.focusDown)                                             -- Focus a la siguiente ventana
        , ("M-<Up>", windows W.focusUp)                                                 -- Focus a la ventana anterior
        , ("M-S-<Down>", windows W.swapDown)                                            -- Cambiar posicion de ventana hacia abajo
        , ("M-S-<Up>", windows W.swapUp)                                                -- Cambiar posicion de ventana hacia arriba
        , ("M-<Backspace>", promote)                                                    -- Mover la ventana como master principal
        , ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP)                   -- Cambiar ventana en el siguiente grupo de trabajo (tecla +)
        , ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP)              -- Cambiar ventana al anterior grupo de trabajo (tecla -)


    -- Layouts
        , ("M-<Tab>", sendMessage NextLayout)                                        -- Cambiar de diseno de ventanas
        , ("M-S-f", sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts)         -- Ventana todo pantalla
        , ("M-<KP_Multiply>", sendMessage (IncMasterN 1))                            -- Incrementar el numero de venatas para un grupo de trabajo o dividir pantall vertical
        , ("M-<KP_Divide>", sendMessage (IncMasterN (-1)))                           -- Decrementar el numero de venatas para un grupo de trabajo o dividir pantall horizontal
        , ("M-S-<KP_Multiply>", increaseLimit)                                       -- Mover para de ventana para delante por los diferentes grupos de trabajo
        , ("M-S-<KP_Divide>", decreaseLimit)                                         -- Mover para de ventana para atras por los diferentes grupos de trabajo
        , ("M-S-<Left>", sendMessage Shrink)                                         -- Aumentar tamano de ancho izquierda
        , ("M-S-<Right>", sendMessage Expand)                                        -- Aumentar tamano de ancho derecha

    -- Para varios monitores
        , ("M-.", nextScreen)                                                      -- Cambiar al siguiente monitor
        , ("M-,", prevScreen)                                                      -- Cambiar al monitor previo

    --- Programas
        , ("M-d", spawn "rofi -show run")
        , ("M-p", spawn "flameshot gui")
        , ("M-<Return>", spawn (myTerminal ++ " -e zsh"))
        , ("M-S-d", spawn "dmenu_run -i -p \"dmenu: \"")
        , ("M-S-c", spawn "galculator")

    -- Media Keys
        , ("<XF86AudioPlay>", spawn "deadbeef --play-pause")
        , ("<XF86AudioStop>", spawn "deadbeef --stop")
        , ("<XF86AudioPrev>", spawn "deadbeef --prev")
        , ("<XF86AudioNext>", spawn "deadbeef --next")
        , ("<XF86MonBrightnessUp>", spawn "bright")
        , ("<XF86MonBrightnessDown>", spawn "bright -d")
        , ("<XF86AudioMute>",   spawn "amixer set Master toggle")
        , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
        , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
        , ("<XF86HomePage>", spawn "qutebrowser")
        , ("<XF86Search>", safeSpawn "qutebrowser" ["https://www.duckduckgo.com/"])
        , ("<XF86Mail>", runOrRaise "geary" (resource =? "thunderbird"))
        , ("<XF86Calculator>", runOrRaise "gcalctool" (resource =? "gcalctool"))
        , ("<XF86Eject>", spawn "toggleeject")
        , ("<Print>", spawn "scrotd 0")
        ] where nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))
                nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))


----------------------------------------------------------------------------------
---                        ESPACIOS DE TRABAJO                                 ---
----------------------------------------------------------------------------------
xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myWorkspaces    = ["www","term","dev","docs","chat","vbox","play","misc","vpn","obs"]
--myWorkspaces    = ["1","2","3","4","5","6","7","8","9","10"]
--myWorkspaces    = ["I","II","III","IV","V","VI","VII","VIII","IX","X"]


-- window manipulations
myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll . concat $
    [ [isDialog --> doCenterFloat]
    , [className =? c --> doCenterFloat | c <- myCFloats]
    , [title =? t --> doFloat | t <- myTFloats]
    , [resource =? r --> doFloat | r <- myRFloats]
    , [resource =? i --> doIgnore | i <- myIgnores]
    , [className =? "discord"             --> doShift ( myWorkspaces !! 4 )]
    , [className =? "VirtualBox Manager"  --> doShift ( myWorkspaces !! 5 )]
    , [className =? "TelegramDesktop"    --> doShift ( myWorkspaces !! 4 )]
    , [className =? "Brave-browser"       --> doShift ( myWorkspaces !! 0 )]
    ]

    where
    -- doShiftAndGo = doF . liftM2 (.) W.greedyView W.shift
    myCFloats = ["Arandr", "Arcolinux-calamares-tool.py", "Arcolinux-tweak-tool.py", "Arcolinux-welcome-app.py", "Galculator", "feh", "mpv", "Xfce4-terminal"]
    myTFloats = ["Downloads", "Save As..."]
    myRFloats = []
    myIgnores = ["desktop_window"]

----------------------------------------------------------------------------------
---                      DISENO DE ESPACIOS DE TRABAJO                         ---
----------------------------------------------------------------------------------
myLayoutHook =  avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats $
               mkToggle (NBFULL ?? NOBORDERS ?? EOT) $ myDefaultLayout
             where
                  myDefaultLayout = threeCol ||| threeRow

-- Descomentar para agregar mas disenos
--myDefaultLayout = tall ||| grid ||| threeCol ||| threeRow ||| oneBig ||| noBorders monocle ||| space ||| floats
--tall         = renamed [Replace "tall"]     $ limitWindows 12 $ spacing 6 $ ResizableTall 1 (3/100) (1/2) []
--grid       = renamed [Replace "grid"]       $ limitWindows 12 $ spacing 6 $ mkToggle (single MIRROR) $ Grid (16/10)
threeCol   = renamed [Replace "threeCol"]   $ limitWindows 3  $ ThreeCol 1 (3/100) (1/2)
threeRow   = renamed [Replace "threeRow"]   $ limitWindows 3  $ Mirror $ ResizableTall 1 (3/100) (1/2) []
--oneBig     = renamed [Replace "oneBig"]   $ limitWindows 6  $ Mirror $ mkToggle (single MIRROR) $ mkToggle (single REFLECTX) $ mkToggle (single REFLECTY) $ OneBig (5/9) (8/12)
--monocle      = renamed [Replace "monocle"]  $ limitWindows 20 $ Full
--space      = renamed [Replace "space"]    $ limitWindows 4  $ spacing 12 $ Mirror $ mkToggle (single MIRROR) $ mkToggle (single REFLECTX) $ mkToggle (single REFLECTY) $ OneBig (2/3) (2/3)
floats       = renamed [Replace "floats"]   $ limitWindows 20 $ simplestFloat

