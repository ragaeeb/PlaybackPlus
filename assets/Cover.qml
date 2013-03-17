import bb.cascades 1.0

Container
{
    property string currentFile
    
    background: back.imagePaint
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    bottomPadding: 40; topPadding: 10; leftPadding: 10; rightPadding: 10
    
    attachedObjects: [
        ImagePaintDefinition {
            id: back
            imageSource: "asset:///images/title_bg.png"
        }
    ]
    
    layout: DockLayout {}
    
    ImageView {
        imageSource: "asset:///images/logo.png"
        topMargin: 0
        leftMargin: 0
        rightMargin: 0
        bottomMargin: 0

        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Bottom
    }
    
    Label {
        text: currentFile
        multiline: true
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Top
        textStyle.textAlign: TextAlign.Center
        textStyle.fontSize: FontSize.XXSmall
    }
}