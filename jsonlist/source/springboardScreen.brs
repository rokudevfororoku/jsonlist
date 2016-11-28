'**********************************************************
'**  springboardScreen
'**********************************************************

Function createSpringboardScreen(dataURL As String, style As String) As Object
    print "creando pantalla poster para " + dataURL
    obj = CreateObject("roAssociativeArray")
    screenport = CreateObject("roMessagePort")
    obj.Port = screenport
    screen = CreateObject("roSpringboardScreen")
    if style <> "movie" and style <> "movie" and style <> "video" then
        screen.SetDescriptionStyle("generic")
    else
        screen.SetDescriptionStyle(style)
    end if
    screen.SetMessagePort(screenport)
    obj.Screen = screen
    obj.Init = initSpringboardScreen
    obj.Show = showSpringboardScreen
    obj.url = dataURL
    obj.LoadData = springboardLoadData   
    obj.Content = CreateObject("roAssociativeArray")
    return obj
End Function


Sub showSpringboardScreen()
    loaded = m.LoadData()
    if loaded then
        m.Init()
        while true
            msg = wait(0, m.screen.GetMessagePort())
            if type(msg) = "roSpringboardScreenEvent" then
                if msg.isScreenClosed()                
                    exit while
                else if msg.isButtonPressed()                             
                    if msg.GetIndex() = 1                                         
                        displayVideo(m.Content)
                    endif
                end if
            else
                print "mensaje inesperado : "; type(msg)
            end if
        end while
    else
        print "no se pudo obtener informacion valida"
    end if
End Sub


Function initSpringboardScreen()
    m.Screen.ClearButtons()
    m.Screen.AddButton(1, "Reproducir")
    m.Screen.SetContent(m.Content)
    m.Screen.Show()
End Function


Function springboardLoadData() as boolean
    if m.url.Left(3) = "pkg" then
        json_response = ReadAsciiFile(m.url)
    else if m.url.Left(4) = "http" then
        json_response = json_from_http(m.url)
    else
        print "url invalida"
        return false
    endif
    if json_response <> invalid and json_response <> "" then
        json_object = ParseJSON(json_response)
        if json_object <> invalid then
            o = init_springboard_item()
            if json_object.DoesExist("Title") then o.Title = json_object.Title
            if json_object.DoesExist("Description") then o.Description = json_object.Description
            if json_object.DoesExist("HDPosterUrl") then o.HDPosterUrl = json_object.HDPosterUrl
            if json_object.DoesExist("SDPosterUrl") then o.SDPosterUrl = json_object.SDPosterUrl                
            if json_object.DoesExist("Rating") then o.Rating = json_object.Rating
            if json_object.DoesExist("StarRating") then o.StarRating = json_object.StarRating
            if json_object.DoesExist("ReleaseDate") then o.ReleaseDate = json_object.ReleaseDate
            if json_object.DoesExist("Length") then o.Length = json_object.Length
            if json_object.DoesExist("Categories") then 
                o.Categories = CreateObject("roArray", 5, true)
                for each category in json_object.Categories
                    o.Categories.Push(category)
                end for
            end if
            if json_object.DoesExist("Actors") then
                o.Actors = CreateObject("roArray", 10, true)
                for each actor in json_object.Actors
                    o.Actors.Push(actor)
                end for
            end if
            if json_object.DoesExist("Director") then o.Director = json_object.Director
            if json_object.DoesExist("streamformat") then o.StreamFormat = json_object.streamformat
            if json_object.DoesExist("StreamBitRates") then
                o.StreamBitRates = CreateObject("roArray", 3, true)
                for each bitrate in json_object.StreamBitRates
                    o.StreamBitRates.Push(bitrate.toint())
                end for
            end if
            if json_object.DoesExist("StreamQualities") then
                o.StreamQualities = CreateObject("roArray", 3, true)
                for each streamquality in json_object.StreamQualities
                    o.StreamQualities.Push(streamquality)
                end for
            end if
            if json_object.DoesExist("StreamUrls") then o.StreamUrls = json_object.StreamUrls
            '    print "we have stream urls"
            '    print json_object.StreamUrls
            '    o.StreamUrls = CreateObject("roArray", 3, true)
            '    for each surl in json_object.StreamUrls         
            '        o.StreamUrls.Push(surl)
            '    end for
            'end if
            m.Content = o
            return true
        else
            print "formato invalido"
            return false
        end if
    else
        print "respuesta invalida"
        return false
    end if
End Function


Function init_springboard_item() As Object
    o = CreateObject("roAssociativeArray")
    o.Title                 = ""
    o.ContentType           = "movie"
    o.Description           = ""    
    o.HDPosterUrl           = "pkg:/imagenes/movie.png"
    o.SDPosterUrl           = "pkg:/imagenes/movie.png"
    o.ShortDescriptionLine1 = ""
    o.ShortDescriptionLine2 = ""    
    o.Rating                = ""
    o.StarRating            = 20
    o.bitrates              = [0]
    o.qualities             = ["SD"]
    o.streamformat          = "mp4"    
    o.Director              = ""
    o.ReleaseDate           = ""
    o.IsHD                  =false
    o.HDBranded             =false
    o.Length                =300
    return o
End Function
