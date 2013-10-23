import bb.cascades 1.0
import bb.device 1.0
import com.canadainc.data 1.0

Dialog
{
    id: root
    property variant position
    
    onPositionChanged: {
        textArea.hintText = formatter.formatTime(position);
    }
    
    Container
    {
        preferredWidth: displayInfo.pixelSize.width
        preferredHeight: displayInfo.pixelSize.height
        background: Color.create(0.0, 0.0, 0.0, 0.5)
        layout: DockLayout {}
        
        gestureHandlers: [
            TapHandler {
                onTapped: {
                    if (event.propagationPhase == PropagationPhase.AtTarget)
                    {
                        if (textArea.text.length > 0) {
                            app.addBookmark(position, textArea.text);
                            persist.showToast("Saved bookmark!");
                        }

                        root.close();
                    }
                }
            }
        ]
        
        Container
        {
            maxHeight: displayInfo.pixelSize.height/2
            bottomPadding: 30
            
            TextArea {
                id: textArea
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
            }
        }
        
        attachedObjects: [
            DisplayInfo {
                id: displayInfo
            }
        ]
    }
    
    onOpened: {
        textArea.resetText();
        textArea.requestFocus();
    }
    
    attachedObjects: [
        TextUtils {
            id: formatter
        }
    ]
}