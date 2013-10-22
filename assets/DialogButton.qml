import bb.cascades 1.0

Container {
    property alias imageButtonInstance: dialogImgButton
    property string dialogButtonLabel: ""
    property string imageUrl: "asset:///images/Dialogs/default_button.png"
    property bool buttonTouchDown: false

    layout: DockLayout {
    }
    
    preferredHeight: 79
    
    leftPadding: 20
    rightPadding: 20

    ImageButton {
        id: dialogImgButton
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill

        defaultImageSource: "asset:///images/Dialogs/default_button.png"
        pressedImageSource: "asset:///images/Dialogs/pressed_button.png"
        disabledImageSource: "asset:///images/Dialogs/disabled_button.png"
    }

    Container {
        layout: DockLayout {
        }
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        leftPadding: 5
        rightPadding: 5
        topPadding: 5
        bottomPadding: 5
        overlapTouchPolicy: OverlapTouchPolicy.Allow

        Label {
            id: buttonLabel
            textStyle.color: buttonTouchDown ? Color.White : Color.Black
            textStyle.textAlign: TextAlign.Center
            preferredHeight: 79
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center

            text: dialogButtonLabel
            overlapTouchPolicy: OverlapTouchPolicy.Allow
            onTouch: {
                if (event.isDown()) {
                    buttonTouchDown = true
                    imageUrl = "asset:///images/Dialogs/pressed_button.png"
                } else {
                    buttonTouchDown = false
                    imageUrl = "asset:///images/Dialogs/default_button.png"
                }
            }

            onTouchExit: {
                imageUrl = "asset:///images/Dialogs/default_button.png"
                buttonTouchDown = false
            }
        }
    }
}
