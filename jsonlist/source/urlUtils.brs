'**********************************************************
'**  urlUtils.brs  
'**  interface http para peticiones json
'** 
'**********************************************************

Function json_from_http(url As String) As String
    print "intentando " + url
    request = NewHttp(url)
    return request.GetToStringWithTimeout(5)
End Function


Function NewHttp(url As String) as Object
    obj = CreateObject("roAssociativeArray")
    obj.Http                        = CreateURLTransferObject(url)    
    obj.GetToStringWithTimeout      = http_get_to_string_with_timeout
    return obj
End Function


Function CreateURLTransferObject(url As String) as Object    
    obj = CreateObject("roUrlTransfer")
    obj.SetPort(CreateObject("roMessagePort"))
    obj.SetUrl(url)          
    obj.AddHeader("Content-Type", "application/x-www-form-urlencoded")
    obj.EnableEncodings(true)
    return obj
End Function


Function http_get_to_string_with_timeout(seconds as Integer) as String
    timeout% = 1000 * seconds
    str = ""
    m.Http.EnableFreshConnection(true) 'Don't reuse existing connections
    if (m.Http.AsyncGetToString())
        event = wait(timeout%, m.Http.GetPort())
        if type(event) = "roUrlEvent"
            str = event.GetString()
        else if event = invalid
            print "AsyncGetToString timeout"
            m.Http.AsyncCancel()
        else
            print "AsyncGetToString evento desconocido"
            print event
        endif
    endif

    return str
End Function
