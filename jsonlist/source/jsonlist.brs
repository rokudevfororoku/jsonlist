' ********************************************************************
' **  Aplicacion jsonlist para roku
' **  Para mas informacion visita http://fororoku.com/foro
' ********************************************************************

Sub Main()
    ' esta es la url donse se encuentra la informacion de la lista
    ' editar la url para que refleje la url de nuestro servidor web
    videolist_url = "http://10.0.0.129/roku/json/videolista.json"
    style = "scale-to-fit"

    'inicializamos los atributos del tema como logo, colores, etc. 
    initTheme()
    'creamos una pantalla vacia para que la aplicacion no salga
    'de regreso al menu principal del roku.
    screenFacade = CreateObject("roPosterScreen")
    screenFacade.show()

    'creamos una pantalla tipo Netflix con la lista
    gridScreen = createVideoGridScreen(videolist_url, style)
    if gridScreen.load_data() then
        gridScreen.Show()
    else
        print "no se pudo obtener la lista de videos"
    end if
    print "terminando aplicacion"

    'salir
    screenFacade.showMessage("")
    sleep(25)
End Sub

'*************************************************************
'** Atributos configurables para la presentacion
'** cabecera, logo, etc.
'*************************************************************

Sub initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    background = "#f2f2f2"
    theme.BackgroundColor = background
    theme.GridScreenBackgroundColor = background    

    theme.OverhangPrimaryLogoOffsetSD_X = "72"
    theme.OverhangPrimaryLogoOffsetSD_Y = "13" 
    theme.OverhangSliceSD = "pkg:/imagenes/ovhg_bgnd_SD.png"
    theme.OverhangPrimaryLogoSD  = "pkg:/imagenes/logo_SD.png"

    theme.GridScreenLogoOffsetSD_X = "72"
    theme.GridScreenLogoOffsetSD_Y = "13"
    theme.GridScreenOverhangSliceSD = "pkg:/imagenes/ovhg_bgnd_SD.png"
    theme.GridScreenLogoSD = "pkg:/imagenes/logo_SD.png" 
    theme.GridScreenOverhangHeightSD = "83"

    theme.OverhangPrimaryLogoOffsetHD_X = "123"
    theme.OverhangPrimaryLogoOffsetHD_Y = "18" 
    theme.OverhangSliceHD = "pkg:/imagenes/ovhg_bgnd_HD.png"
    theme.OverhangPrimaryLogoHD  = "pkg:/imagenes/logo_HD.png"

    theme.GridScreenLogoOffsetHD_X = "123"
    theme.GridScreenLogoOffsetHD_Y = "18"
    theme.GridScreenOverhangSliceHD = "pkg:/imagenes/ovhg_bgnd_HD.png"
    theme.GridScreenLogoHD = "pkg:/imagenes/logo_HD.png"
    theme.GridScreenOverhangHeightHD = "138"

    theme.SubtitleColor = "#dc00dc"
    
    app.SetTheme(theme)

End Sub


'*************************************************************
'** displayVideo()
'** esta funcion reproduce el video
'*************************************************************
Sub displayVideo(videoclip as object)
    if videoclip <> invalid and type(videoclip) = "roAssociativeArray" then        
        p = CreateObject("roMessagePort")
        video = CreateObject("roAssociativeArray")
        video.StreamBitrates = videoclip.bitrates        
        video.StreamUrls = videoclip.StreamUrls        
        video.StreamQualities = videoclip.qualities        
        video.StreamFormat = videoclip.streamformat        
        video.Title = videoclip.Title   
        videoscreen = CreateObject("roVideoScreen")
        videoscreen.setMessagePort(p)            
        videoscreen.SetContent(video)    
        videoscreen.show()
        lastSavedPos   = 0
        statusInterval = 10 
        print "Reproduciendo video: " + videoclip.Title
        while true
            msg = wait(0, videoscreen.GetMessagePort())
            if type(msg) = "roVideoScreenEvent"
                if msg.isScreenClosed() then 
                    print "Cerrando pantalla de video"
                    exit while
                else if msg.isPlaybackPosition() then
                    nowpos = msg.GetIndex()                    
                    if nowpos > 0
                        if abs(nowpos - lastSavedPos) > statusInterval
                            lastSavedPos = nowpos
                        end if
                    end if
                else if msg.isRequestFailed()
                    print "Falla en la reproduccion: "; msg.GetMessage()
                else
                    print "Evento desconocido: "; msg.GetType(); " mensaje: "; msg.GetMessage()
                end if
            end if
        end while
    else
        print "contenido invalido"
    end if
End Sub
