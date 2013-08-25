import bb.cascades 1.0

Page
{
    ScrollView
    {
        leftPadding: 20; topPadding: 20; rightPadding: 20; bottomPadding: 20
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            SettingPair
            {
                title: qsTr("Landscape Lock") + Retranslate.onLanguageChanged
                key: "landscape"
                
                toggle.onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("The app will be locked to the landscape orientation.")
                        OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.DisplayLandscape
                    } else {
                        infoText.text = qsTr("The app will not be locked to just the landscape orientation.")
                        OrientationSupport.supportedDisplayOrientation = SupportedDisplayOrientation.All
                    }
                }
            }
            
            SettingPair {
                topMargin: 20;
                bottomPadding: 40
                title: qsTr("Stretch Video") + Retranslate.onLanguageChanged
                key: "stretch"
                
                toggle.onCheckedChanged: {
                    if (checked) {
                        infoText.text = qsTr("The video will be stretched to fill the entire screen.")
                    } else {
                        infoText.text = qsTr("The video will not be stretched to fill the entire screen.")
                    }
                }
            }
            
            Label {
                id: infoText
                multiline: true
                textStyle.fontSize: FontSize.XXSmall
                textStyle.textAlign: TextAlign.Center
                verticalAlignment: VerticalAlignment.Bottom
                horizontalAlignment: HorizontalAlignment.Center
            }
        }
    }
}