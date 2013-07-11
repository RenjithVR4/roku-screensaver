' Main() is useful for testing. It should be commented
' out before this is checked in.
Sub Main()
 
   facade = CreateObject("roParagraphScreen")
   facade.Show()
   RunScreenSaver()
End Sub


' The screensaver entry point.
Sub RunScreenSaver()
   api_url = "http://www.cutecaptions.com/roku-api.php"
   json = fetch_JSON(api_url)

   maxWidth = 400
   maxHeight = null
   ypos = 0
   di = CreateObject("roDeviceInfo")
   displayMode = di.GetDisplayMode()
   screenWidth = int(di.GetDisplaySize().w)
   screenHeight = int(di.GetDisplaySize().h)
   captionBoxWidth = 600
   captionY = null  ' will set this based on aspect ratio later
   captionX = int((screenWidth / 2) - (captionBoxWidth / 2))

   canvas = CreateObject("roImageCanvas")
   port = CreateObject("roMessagePort")
   canvas.SetMessagePort(port)
   canvas.SetLayer(0, {Color:"#FF000000", CompositionMode:"Source"}) 
   canvas.SetRequireAllImagesToDraw(false)

   while(true)



    for each img in json
  print img.title

width = int(img.width)
height = int(img.height)

    ' calculate the image x axis so we can center it

     if (displayMode = "480i") then
        captionY = int(screenHeight) - 75
        maxHeight = 370
        
        if (width > maxWidth)
          diff =   width - maxWidth
          percentToScale = abs(1-(diff/width)) 
          print percentToScale
          width = int(width * percentToScale)
          height = int(height * percentToScale)
        end if
     else 

        captionY = int(screenHeight) - 125
        maxHeight = int(screenHeight) - 185

     end if

    ' print displayMode
     print di.GetDisplaySize()

    'always check for MaxHeight 
    if (height > maxHeight)
      diff =   height - maxHeight
      percentToScale = abs(1-(diff/height)) 
      print percentToScale
      width = int(width * percentToScale)
      height = int(height * percentToScale)
    end if


xpos = (screenWidth / 2)  -  (width / 2)
xpos = int(xpos)

ypos = (screenHeight / 2) - (height / 2)
ypos = int(ypos - 30)




print screenWidth
print width
print xpos


    canvasItems = [
        {   
            url:img.url
            TargetRect:{x:xpos,y:ypos,w:width,h:height}

        },
        { 
            Text:img.title
            TextAttrs:{Color:"#FFCCCCCC", Font:"Medium",
            HAlign:"HCenter", VAlign:"VCenter",
            Direction:"LeftToRight"}
            ' TargetRect:{x:390,y:captionY,w:500,h:60}
            TargetRect:{x:captionX,y:captionY,w:captionBoxWidth,h:60}
        }
    ] 


   canvas.SetLayer(1, canvasItems)
   canvas.Show() 




       msg = wait(12000,port) 
       if type(msg) = "roImageCanvasEvent" then
           if (msg.isRemoteKeyPressed()) then
               i = msg.GetIndex()
               print "Key Pressed - " ; msg.GetIndex()
               if (i = 2) then
                   canvas.close()
               end if
           else if (msg.isScreenClosed()) then
               print "Closed"
               return
           end if
       end if



      end for



   end while
    
End Sub



Function fetch_JSON(url as string) as Object

print "fetching new JSON"

xfer=createobject("roURLTransfer")
xfer.seturl(url)
data=xfer.gettostring()
json = ParseJSON(data)

  return json
End Function


