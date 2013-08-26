import bb.cascades 1.0

Container
{
    background: back.imagePaint
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    bottomPadding: 10; topPadding: 10; leftPadding: 10; rightPadding: 10
    
    layout: DockLayout {}
    
    attachedObjects: [
        ImagePaintDefinition {
            id: back
            imageSource: "images/title_bg.png"
        }
    ]
    
    Label {
        text: qsTr("Playback Plus") + Retranslate.onLanguageChanged
        multiline: true
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        textStyle.textAlign: TextAlign.Center
        textStyle.fontSize: FontSize.XXSmall
        
        function onMetaDataChanged(metadata) {
            var uri = metadata.uri;
            uri = uri.substring( uri.lastIndexOf("/")+1 );
            uri = uri.substring( 0, uri.lastIndexOf(".") );
            
            text = uri;
        }
        
        onCreationCompleted: {
            player.metaDataChanged.connect(onMetaDataChanged);
            onMetaDataChanged(player.metaData);
        }
    }
}