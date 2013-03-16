import bb.cascades 1.0

Label {
    property double toValue
    
    id: shifter
    textStyle.fontSize: FontSize.XXLarge
    horizontalAlignment: HorizontalAlignment.Center
    verticalAlignment: VerticalAlignment.Center
    scaleX: 4
    scaleY: scaleX
    visible: false
    opacity: 0
    
    function animate() {
        visible = true
        fadeIn.play()
    }
    
    animations: [
        ParallelAnimation
        {
            id: fadeIn
            
            SequentialAnimation
            {
                FadeTransition {
                    fromOpacity: 0
                    toOpacity: 1
                    duration: 1000
                }
                
                FadeTransition {
                    fromOpacity: 1
                    toOpacity: 0
                    duration: 1000
                }
            }
            
            TranslateTransition {
                toX: toValue
                duration: 2000
            }
            
            onEnded: {
                shifter.translationX = 0
                shifter.visible = false
            }
        }
    ]
}