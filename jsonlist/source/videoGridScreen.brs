'******************************************************
'** videoGridScreen 
'** 
'******************************************************

Function createVideoGridScreen(data_url As String, style As String) As Object
    obj = CreateObject("roAssociativeArray")
    screenport = CreateObject("roMessagePort")
    obj.Port = screenport
    screen = CreateObject("roGridScreen")
    screen.SetMessagePort(screenport)
    screen.SetGridStyle(style)
    obj.Screen = screen
    obj.url = data_url
    obj.load_data = video_load_data
    obj.row_count = 0
    obj.content_list = []
    obj.content_type = "videos"
    obj.Show = videoShow
    obj.Title = ""
    return obj    
End Function


Sub videoShow() 
    m.cur_row = 0
    m.cur_item     = 0 
    m.Screen.Show()        

    while true
        msg = wait(0, m.Port)        
        print "tenemos mensaje:";type(msg)
        if type(msg) = "roGridScreenEvent" then
            print "msg= "; msg.GetMessage() " , indice= "; msg.GetIndex(); " data= "; msg.getData()
            if msg.isListItemFocused() then
                print"seleccionado | video = "; msg.GetIndex()
            else if msg.isListItemSelected() then
                row = msg.GetIndex()
                m.cur_row = row
                selection = msg.getData()
                m.cur_item = selection                        
                selected = m.content_list[m.cur_row].items[m.cur_item]
                new_screen = createSpringboardScreen(selected.MetaUrl, selected.ContentType)
                new_screen.Show()
                           
            else if msg.isScreenClosed() then
                print "cerrando pantalla"
                exit while
            end if
        end If
    end while
End Sub


Function video_load_data() as boolean
    json_response = ""
    if m.URL.Left(3) = "pkg" then
        json_response = ReadAsciiFile(m.URL)
    else if m.URL.Left(4) = "http" then
        json_response = json_from_http(m.URL)
    else        
        print "url invalida"
        return false
    end if

    if json_response <> invalid and json_response <> "" then
        json_object = ParseJSON(json_response)
        if json_object <> invalid then
            max_col = 6
            item_count = json_object.Videos.Count()
            row_count = 0
            while true
                row_count = row_count + 1
                if item_count - 6 < 0 then exit while
                item_count = item_count - 6
            end while
            m.row_count = row_count
            for i = 0 to row_count - 1
                row_arr = init_video_row()
                m.content_list.Push(row_arr)
            end for
            row_count = 0
            col_count = 0
            for each item in json_object.videos
                col_count = col_count + 1
                if col_count > max_col then
                    col_count = 0
                    row_count = row_count +1
                end if
                new_item = init_videogrid_item()
                if item.DoesExist("Title") then new_item.Title = item.Title
                if item.DoesExist("HDPosterUrl") then new_item.HDPosterUrl = item.HDPosterUrl
                if item.DoesExist("SDPosterUrl") then new_item.SDPosterUrl = item.SDPosterUrl
                if item.DoesExist("Rating") then new_item.Rating = item.Rating
                if item.DoesExist("StarRating") then new_item.StarRating = item.StarRating  
                if item.DoesExist("Description") then new_item.Description = item.Description
                if item.DoesExist("ReleaseDate") then new_item.ReleaseDate = item.ReleaseDate
                if item.DoesExist("MetaUrl") then new_item.MetaUrl = item.MetaUrl
                if item.DoesExist("ContentType") then new_item.ContentType = item.ContentType
                m.content_list[row_count].items.Push(new_item)
            end for
            m.Screen.SetupLists(m.row_count)
   
            for i = 0 to m.row_count -1                
                m.Screen.SetContentList(i, m.content_list[i].items)
            end for 
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


Function init_video_row() As Object
    o = CreateObject("roAssociativeArray")
    o.Title       = ""    
    o.items       = CreateObject("roArray", 100, true)    
    return o
End Function


Function init_videogrid_item() As Object
    o = CreateObject("roAssociativeArray")    
    o.Title            = ""
    o.ContentType      = "movie"
    o.HDPosterUrl      = "pkg:/imagenes/movie.png"
    o.SDPosterUrl      = "pkg:/imagenes/movie.png"   
    o.Rating           = "AA"
    o.StarRating       = 20    
    o.ReleaseDate      = ""
    o.MetaUrl          = "http://localhost/video.json"
    o.Description      = "Descripcion no disponible"
    return o
End Function
